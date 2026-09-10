#include <jni.h>
#include <android/log.h>
#include <string>
#include "overlay.h"
#include "hook.h"

#define LOG_TAG "JZSBrawl"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

extern "C" JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* reserved) {
    LOGI("JZS Brawl v69.230 - chargement...");

    JNIEnv* env = nullptr;
    if (vm->GetEnv((void**)&env, JNI_VERSION_1_6) != JNI_OK) {
        return JNI_ERR;
    }

    // Initialise l'overlay texte (gold, haut gauche)
    Overlay::init(vm);

    // Pose le hook sur eglSwapBuffers pour render à chaque frame
    Hook::setup();

    LOGI("JZS Brawl charge avec succes !");
    return JNI_VERSION_1_6;
}
