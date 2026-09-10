/* libJZS.so - lib native JZS Brawl (minimale, zéro dépendance externe)
   Premier feature natif : nGetBuild() prouve que la lib se charge et tourne.
   Pas d'appel à la table JNI ni à liblog => aucun symbole non résolu => load garanti. */

typedef int jint;
typedef void* JavaVM;
typedef void* JNIEnv;
typedef void* jclass;

#define JNI_VERSION_1_6 0x00010006

/* Appelé automatiquement quand System.loadLibrary("JZS") réussit */
__attribute__((visibility("default")))
jint JNI_OnLoad(JavaVM* vm, void* reserved) {
    return JNI_VERSION_1_6;
}

/* Méthode native : com.jzsbrawl.Native.nGetBuild() -> renvoie le build number.
   Si le smali reçoit 69230, la lib native est bien chargée et fonctionnelle. */
__attribute__((visibility("default")))
jint Java_com_jzsbrawl_Native_nGetBuild(JNIEnv* env, jclass clazz) {
    return 69230;
}
