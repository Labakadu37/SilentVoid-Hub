#pragma once
#include <jni.h>
#include <string>

namespace Overlay {
    void init(JavaVM* vm);
    void render();  // appelé à chaque frame via le hook eglSwapBuffers
}
