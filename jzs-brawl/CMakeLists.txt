cmake_minimum_required(VERSION 3.22.1)
project(JZSBrawl)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 -fvisibility=hidden")

add_library(JZS SHARED
    src/main.cpp
    src/overlay.cpp
)

target_include_directories(JZS PRIVATE include)

target_link_libraries(JZS
    android
    log
)
