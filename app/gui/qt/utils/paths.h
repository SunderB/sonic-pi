#ifndef PATHS_H
#define PATHS_H
  // diversity is the spice of life
  #if defined(Q_OS_MAC)
    #define ROOT_PATH QCoreApplication::applicationDirPath() + "/../Resources"
  #elif defined(Q_OS_WIN)
      // CMake builds, the exe is in build/debug/sonic-pi, etc.
      // We should pass this to the build instead of wiring it up this way!
    #define ROOT_PATH QCoreApplication::applicationDirPath() + "/../../.."
  #else
      // On linux, CMake builds app into the build folder
    #define ROOT_PATH QCoreApplication::applicationDirPath() + "/../.."
  #endif
#endif
