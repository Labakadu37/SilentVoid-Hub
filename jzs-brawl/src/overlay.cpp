#include "overlay.h"
#include <jni.h>
#include <android/log.h>
#include <GLES2/gl2.h>
#include <string>
#include <vector>

#define LOG_TAG "JZSBrawl"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

// ─── Config du texte affiché ───────────────────────────────────────────────
static const std::vector<std::string> OVERLAY_LINES = {
    "JZS Brawl v69.230 - (release)",
    "Telegram: t.me/jzbrawl",
};

// Couleur or : R=255 G=215 B=0
static const float GOLD_R = 1.0f;
static const float GOLD_G = 0.843f;
static const float GOLD_B = 0.0f;

// ─── Variables internes ────────────────────────────────────────────────────
static JavaVM* g_vm       = nullptr;
static jclass  g_cls      = nullptr;  // référence à notre classe Java helper
static jmethodID g_drawTextMethod = nullptr;

// ─── Shader minimal pour dessiner du texte via OpenGL ES 2 ────────────────
// (approche : on délègue le rendu texte à une View Android via JNI
//  pour éviter d'embarquer une lib de font complète dans le .so)

namespace Overlay {

void init(JavaVM* vm) {
    g_vm = vm;
    LOGI("Overlay init - lignes a afficher : %zu", OVERLAY_LINES.size());
    for (auto& line : OVERLAY_LINES) {
        LOGI("  > %s", line.c_str());
    }
}

// Appelé à chaque swap de frame (hook eglSwapBuffers)
void render() {
    if (!g_vm) return;

    JNIEnv* env = nullptr;
    bool attached = false;

    if (g_vm->GetEnv((void**)&env, JNI_VERSION_1_6) == JNI_EDETACHED) {
        g_vm->AttachCurrentThread(&env, nullptr);
        attached = true;
    }

    if (!env) return;

    // Trouve la classe helper au premier appel
    if (!g_cls) {
        jclass local = env->FindClass("com/jzsbrawl/TextOverlay");
        if (local) {
            g_cls = (jclass)env->NewGlobalRef(local);
            g_drawTextMethod = env->GetStaticMethodID(
                g_cls, "drawLines", "([Ljava/lang/String;FFF)V"
            );
        }
    }

    // Construit le tableau de strings et appelle la méthode Java
    if (g_cls && g_drawTextMethod) {
        jclass stringClass = env->FindClass("java/lang/String");
        jobjectArray arr = env->NewObjectArray(
            (jsize)OVERLAY_LINES.size(), stringClass, nullptr
        );
        for (int i = 0; i < (int)OVERLAY_LINES.size(); i++) {
            jstring js = env->NewStringUTF(OVERLAY_LINES[i].c_str());
            env->SetObjectArrayElement(arr, i, js);
            env->DeleteLocalRef(js);
        }
        env->CallStaticVoidMethod(g_cls, g_drawTextMethod,
                                  arr, GOLD_R, GOLD_G, GOLD_B);
        env->DeleteLocalRef(arr);
    }

    if (attached) {
        g_vm->DetachCurrentThread();
    }
}

} // namespace Overlay
