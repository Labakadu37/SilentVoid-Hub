# Construire le client JZS

Comment BSD est fait, et comment reproduire la même chose avec notre propre code.

---

## 1. Ce que fait BSD

| Brique | Chez BSD | Chez nous |
|---|---|---|
| Base | APK Brawl Stars officiel | pareil |
| Moteur du jeu | `libg.so`, patché via des `.ecc` | on n'y touche pas |
| Lib injectée | `libBSD.so` | **`libJZS.so`, à écrire** |
| Dessin de l'overlay | hook du rendu OpenGL | pareil |
| Menu mod | Flutter (`libapp.so`) | plus tard |
| Config | `assets/bsd/` chiffré | `assets/jzs/` en clair |

Le point central : **leur texte est dessiné à l'intérieur du rendu du jeu**, pas
posé par-dessus. C'est pour ça qu'il ne clignote pas, suit le plein écran et
survit au mode immersif. Pour reproduire ça il faut une bibliothèque native
chargée dans le processus du jeu, qui intercepte la boucle de rendu.

---

## 2. Deux chemins

**Chemin A — vue Android par-dessus.** C'est ce qu'on a déjà : `JzsOverlay`
ajoutée sur `android.R.id.content`. Ça marche sur une activité normale (vérifié),
mais rien ne garantit que ça passe au-dessus d'une surface de rendu native.

Si le texte n'apparaît pas dans le jeu, la correction tient en quelques lignes :
passer d'une vue dans l'activité à une **fenêtre système**.

```java
WindowManager wm = (WindowManager) ctx.getSystemService(Context.WINDOW_SERVICE);
WindowManager.LayoutParams lp = new WindowManager.LayoutParams(
        WindowManager.LayoutParams.MATCH_PARENT,
        WindowManager.LayoutParams.MATCH_PARENT,
        WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
        WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                | WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
                | WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
        PixelFormat.TRANSLUCENT);
wm.addView(overlay, lp);
```

Il faut `<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>`
et que l'utilisateur autorise « Affichage par-dessus les autres applis ». Ça se
dessine au-dessus de tout, y compris des surfaces natives. C'est le résultat
visible le plus rapide.

**Chemin B — comme BSD.** Une lib native qui intercepte le rendu. Pas de
permission à accorder, le texte fait partie de l'image du jeu. C'est la suite de
ce document.

---

## 3. Environnement sur PC

```bash
# JDK 17
sudo apt install openjdk-17-jdk

# Android SDK : build-tools + platform
# NDK r26 ou plus recent (pour compiler le C++)
sdkmanager "build-tools;34.0.0" "platforms;android-35" "ndk;26.1.10909125"

# Python 3 pour nos outils
python3 --version
```

Nos scripts sont dans `jzs-mod/tools/`.

---

## 4. La bibliothèque native

### 4.1 Principe

Le jeu dessine chaque image puis appelle `eglSwapBuffers()` pour l'afficher.
Si on intercepte cet appel, on a un point d'entrée exécuté **une fois par image**,
avec un contexte OpenGL actif. On y dessine notre bandeau, puis on laisse le
vrai `eglSwapBuffers` faire son travail.

```
jeu → dessine sa scène → eglSwapBuffers()
                              ↓  (intercepté)
                         notre texte
                              ↓
                         vrai eglSwapBuffers()
```

### 4.2 Arborescence

```
jzs-native/
  CMakeLists.txt
  src/
    jzs_main.cpp      JNI_OnLoad, mise en place
    got_hook.cpp      remplacement d'entrée GOT
    got_hook.h
    overlay_gl.cpp    dessin du texte en OpenGL
    overlay_gl.h
```

### 4.3 Le hook

Sous Android, un appel à une fonction d'une autre bibliothèque passe par la
**GOT** (Global Offset Table). Réécrire l'entrée correspondante redirige l'appel
sans toucher au code de la fonction — c'est la méthode la plus propre et la plus
stable.

`got_hook.cpp` :

```cpp
#include "got_hook.h"
#include <link.h>
#include <sys/mman.h>
#include <unistd.h>
#include <cstring>
#include <string>

namespace {

struct HookRequest {
    const char* lib_suffix;   // ex: "libg.so"
    const char* symbol;       // ex: "eglSwapBuffers"
    void*       replacement;
    void**      original;     // reçoit l'ancienne valeur
    bool        done;
};

// Rend une page inscriptible le temps d'écrire l'entrée.
bool write_pointer(void** slot, void* value) {
    const size_t page = sysconf(_SC_PAGESIZE);
    auto addr = reinterpret_cast<uintptr_t>(slot) & ~(page - 1);
    if (mprotect(reinterpret_cast<void*>(addr), page, PROT_READ | PROT_WRITE) != 0) {
        return false;
    }
    *slot = value;
    mprotect(reinterpret_cast<void*>(addr), page, PROT_READ);
    return true;
}

int visit(struct dl_phdr_info* info, size_t, void* data) {
    auto* req = static_cast<HookRequest*>(data);
    if (req->done || !info->dlpi_name) return 0;

    std::string name(info->dlpi_name);
    if (name.size() < strlen(req->lib_suffix) ||
        name.compare(name.size() - strlen(req->lib_suffix),
                     strlen(req->lib_suffix), req->lib_suffix) != 0) {
        return 0;
    }

    // Localiser le segment dynamique de cette bibliothèque.
    const ElfW(Dyn)* dyn = nullptr;
    for (int i = 0; i < info->dlpi_phnum; i++) {
        if (info->dlpi_phdr[i].p_type == PT_DYNAMIC) {
            dyn = reinterpret_cast<const ElfW(Dyn)*>(
                    info->dlpi_addr + info->dlpi_phdr[i].p_vaddr);
            break;
        }
    }
    if (!dyn) return 0;

    const char*      strtab = nullptr;
    const ElfW(Sym)* symtab = nullptr;
    const ElfW(Rela)* rela  = nullptr;   // arm64 utilise RELA
    const ElfW(Rela)* plt   = nullptr;
    size_t rela_n = 0, plt_n = 0;

    for (const ElfW(Dyn)* d = dyn; d->d_tag != DT_NULL; d++) {
        switch (d->d_tag) {
            case DT_STRTAB:   strtab = reinterpret_cast<const char*>(d->d_un.d_ptr); break;
            case DT_SYMTAB:   symtab = reinterpret_cast<const ElfW(Sym)*>(d->d_un.d_ptr); break;
            case DT_RELA:     rela   = reinterpret_cast<const ElfW(Rela)*>(d->d_un.d_ptr); break;
            case DT_RELASZ:   rela_n = d->d_un.d_val / sizeof(ElfW(Rela)); break;
            case DT_JMPREL:   plt    = reinterpret_cast<const ElfW(Rela)*>(d->d_un.d_ptr); break;
            case DT_PLTRELSZ: plt_n  = d->d_un.d_val / sizeof(ElfW(Rela)); break;
            default: break;
        }
    }
    if (!strtab || !symtab) return 0;

    auto scan = [&](const ElfW(Rela)* table, size_t count) {
        for (size_t i = 0; i < count && !req->done; i++) {
            size_t sym_index = ELF64_R_SYM(table[i].r_info);
            const char* sym_name = strtab + symtab[sym_index].st_name;
            if (strcmp(sym_name, req->symbol) != 0) continue;

            auto** slot = reinterpret_cast<void**>(info->dlpi_addr + table[i].r_offset);
            if (req->original) *req->original = *slot;
            if (write_pointer(slot, req->replacement)) req->done = true;
        }
    };

    if (plt)  scan(plt, plt_n);
    if (rela) scan(rela, rela_n);
    return req->done ? 1 : 0;
}

}  // namespace

bool jzs_hook_got(const char* lib_suffix, const char* symbol,
                  void* replacement, void** original) {
    HookRequest req{lib_suffix, symbol, replacement, original, false};
    dl_iterate_phdr(visit, &req);
    return req.done;
}
```

`got_hook.h` :

```cpp
#pragma once
bool jzs_hook_got(const char* lib_suffix, const char* symbol,
                  void* replacement, void** original);
```

### 4.4 Point d'entrée

`jzs_main.cpp` :

```cpp
#include <jni.h>
#include <EGL/egl.h>
#include <android/log.h>
#include "got_hook.h"
#include "overlay_gl.h"

#define LOG(...) __android_log_print(ANDROID_LOG_INFO, "JZS", __VA_ARGS__)

namespace {
EGLBoolean (*real_swap)(EGLDisplay, EGLSurface) = nullptr;

EGLBoolean jzs_swap(EGLDisplay dpy, EGLSurface surface) {
    jzs::overlay_draw();              // notre bandeau, une fois par image
    return real_swap(dpy, surface);
}
}  // namespace

extern "C" JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM*, void*) {
    // Le jeu appelle eglSwapBuffers depuis son moteur : on cible sa lib.
    bool ok = jzs_hook_got("libg.so", "eglSwapBuffers",
                           reinterpret_cast<void*>(jzs_swap),
                           reinterpret_cast<void**>(&real_swap));
    LOG("hook eglSwapBuffers : %s", ok ? "ok" : "echec");
    return JNI_VERSION_1_6;
}
```

Si le hook sur `libg.so` échoue, essayer `libflutter.so`, ou boucler sur toutes
les bibliothèques chargées. Le log `JZS` dans `logcat` dit immédiatement ce qui
s'est passé :

```bash
adb logcat -s JZS
```

### 4.5 Dessiner le texte

Le plus simple et le plus fiable : **fabriquer l'image du texte côté Java**
(on a déjà `JzsOverlay` qui sait le dessiner sur un `Canvas`), l'envoyer en
bitmap au natif une seule fois, et à chaque image afficher un quad texturé.

Côté Java, produire le bitmap :

```java
Bitmap bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888);
overlay.draw(new Canvas(bmp));          // notre rendu existant
nativeSetOverlayBitmap(bmp);            // vers le natif
```

Côté natif, `overlay_gl.cpp` téléverse ce bitmap en texture GL
(`glTexImage2D`) puis, dans `overlay_draw()`, dessine un rectangle texturé en
haut à gauche avec un shader minimal. Points à respecter :

- sauvegarder et restaurer l'état GL (programme, blend, viewport, buffers)
  autour de notre dessin, sinon on casse le rendu du jeu ;
- activer `GL_BLEND` avec `GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA` pour la
  transparence ;
- ne recréer la texture que si le texte change (ping, joueurs), pas à chaque image.

### 4.6 CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.22)
project(jzs)

add_library(JZS SHARED
    src/jzs_main.cpp
    src/got_hook.cpp
    src/overlay_gl.cpp)

target_link_libraries(JZS EGL GLESv2 log android)
```

Compilation :

```bash
$NDK/ndk-build   # ou cmake avec le toolchain Android
# produit libJZS.so pour chaque ABI
```

---

## 5. Charger notre lib dans le jeu

Deux méthodes.

**Depuis notre Application** (simple, c'est notre code) — dans
`JzsApplication.onCreate()` :

```java
System.loadLibrary("JZS");
```

**Par le linker** (méthode BSD) : ajouter une entrée `DT_NEEDED` dans `libg.so`
pour que le linker charge `libJZS.so` automatiquement. Plus discret, mais ça
modifie le binaire du jeu — la première méthode suffit largement.

---

## 6. Assembler l'APK

Tout est déjà écrit dans `jzs-mod/` :

```bash
./jzs-mod/build-game.sh
```

Le script enchaîne : compilation Java → DEX → fusion du bundle → patch du
manifeste → `zipalign` → signature. Il faut y ajouter la copie de
`libJZS.so` dans `lib/<abi>/`.

---

## 7. Pièges déjà rencontrés

Chacun de ces points a coûté un APK raté. Ils sont tous réglés dans les outils
du dépôt, mais il faut les connaître.

| Piège | Symptôme | Correction |
|---|---|---|
| Signature v1 seule (`jarsigner`) | « Application non installée » | `apksigner` avec v2+v3 |
| Pas de `zipalign` | refus à l'installation | `zipalign -f -p 4` avant signature |
| `resources.arsc` d'une autre version | 54 ressources introuvables | garder celui de la base |
| `requiredSplitTypes` non neutralisé | `INSTALL_FAILED_MISSING_SPLIT` | vider l'attribut + `vending.splits.required` |
| Zip64 (Python au-delà de 2 Go) | `zipalign` ne lit pas l'archive | `zipfile.ZIP64_LIMIT = 0xFFFFFFFF - 1` |
| Remplacer `TitanApplication` | plantage au démarrage | en **hériter**, `super.onCreate()` d'abord |
| DEX nommé en dur | code du jeu écrasé | premier slot `classes<N>.dex` libre |
| Même package qu'une appli installée | « Application non installée » | renommer le package |
| Remplacement de texte trop large | clés JSON renommées, textes introuvables | ne toucher qu'aux **valeurs** |

---

## 8. Ordre de travail conseillé

1. **Chemin A avec fenêtre système** — résultat visible en une heure, valide
   toute la chaîne d'assemblage.
2. **`libJZS.so` + hook** — le rendu intégré, comme BSD.
3. **Backend** — ping et compteur de joueurs réels.
4. **Menu mod** — seulement une fois le reste stable.

Ne pas commencer par l'étape 4. C'est la plus visible mais elle ne sert à rien
tant que l'overlay n'est pas fiable.
