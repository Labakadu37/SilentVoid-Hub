#include <jni.h>
#include <android/log.h>

#define TAG "JZSBrawl"
#define LOG(...) __android_log_print(ANDROID_LOG_INFO, TAG, __VA_ARGS__)

// Point d'entrée principal de libJZS.so
// L'overlay texte est géré côté smali (com/jzsbrawl/JZSOverlay)
// Cette lib est là pour les hooks natifs futurs (game functions, etc.)

extern "C" JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* reserved) {
    LOG("=================================");
    LOG("  JZS Brawl v69.230 - loaded");
    LOG("  Telegram: t.me/jzbrawl");
    LOG("=================================");
    return JNI_VERSION_1_6;
}
