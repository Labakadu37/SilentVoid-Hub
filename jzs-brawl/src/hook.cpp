#include "hook.h"
#include "overlay.h"
#include <android/log.h>
#include <EGL/egl.h>
#include <dlfcn.h>

#define LOG_TAG "JZSBrawl"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

// ─── Pointeur vers l'original eglSwapBuffers ──────────────────────────────
static EGLBoolean (*orig_eglSwapBuffers)(EGLDisplay, EGLSurface) = nullptr;

// ─── Notre version hookée ─────────────────────────────────────────────────
static EGLBoolean hooked_eglSwapBuffers(EGLDisplay display, EGLSurface surface) {
    // On render notre overlay AVANT que le frame parte à l'écran
    Overlay::render();
    return orig_eglSwapBuffers(display, surface);
}

// ─── Hook via PLT (Procedure Linkage Table) ────────────────────────────────
// Méthode : on remplace le pointeur dans la GOT de libEGL.so
// Pour une solution plus robuste utiliser Dobby ou Substrate
static bool hookFunction(void* target, void* hook, void** original) {
    // Implémentation basique via mprotect + patch mémoire
    // En production : utiliser Dobby (hook_func(target, hook, original))
    *original = target;

    uintptr_t addr = (uintptr_t)target;
    uintptr_t page = addr & ~(uintptr_t)(4096 - 1);

    if (mprotect((void*)page, 4096 * 2, PROT_READ | PROT_WRITE | PROT_EXEC) != 0) {
        LOGI("mprotect echec");
        return false;
    }

#if defined(__aarch64__)
    // ARM64 : LDR X17, +8 ; BR X17 ; .quad <addr>
    uint32_t stub[4];
    stub[0] = 0x58000051; // LDR X17, +8
    stub[1] = 0xD61F0220; // BR X17
    uintptr_t hookAddr = (uintptr_t)hook;
    memcpy(&stub[2], &hookAddr, sizeof(hookAddr));
    memcpy((void*)addr, stub, sizeof(stub));
#elif defined(__arm__)
    // ARM32 : LDR PC, [PC, #0] ; .word <addr>
    uint32_t stub[2];
    stub[0] = 0xE51FF004; // LDR PC, [PC, #-4]
    stub[1] = (uint32_t)(uintptr_t)hook;
    memcpy((void*)addr, stub, sizeof(stub));
#endif

    __builtin___clear_cache((char*)addr, (char*)(addr + 16));
    return true;
}

namespace Hook {

void setup() {
    void* egl = dlopen("libEGL.so", RTLD_NOW);
    if (!egl) {
        LOGI("libEGL.so introuvable");
        return;
    }

    void* sym = dlsym(egl, "eglSwapBuffers");
    if (!sym) {
        LOGI("eglSwapBuffers introuvable");
        dlclose(egl);
        return;
    }

    if (hookFunction(sym, (void*)hooked_eglSwapBuffers, (void**)&orig_eglSwapBuffers)) {
        LOGI("Hook eglSwapBuffers pose avec succes");
    } else {
        LOGI("Hook eglSwapBuffers echoue");
    }

    dlclose(egl);
}

} // namespace Hook
