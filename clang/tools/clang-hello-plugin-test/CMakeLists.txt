set( LLVM_LINK_COMPONENTS
  ${LLVM_TARGETS_TO_BUILD}
  Analysis
  CodeGen
  Core
  IPO
  AggressiveInstCombine
  InstCombine
  Instrumentation
  MC
  MCParser
  ObjCARCOpts
  Option
  ScalarOpts
  Support
  TargetParser
  TransformUtils
  Vectorize
  )

# Support plugins.
if(CLANG_PLUGIN_SUPPORT)
  set(support_plugins SUPPORT_PLUGINS)
endif()

add_clang_tool(clang-hello-plugin-test
  ../driver/driver.cpp
  ../driver/cc1_main.cpp
  ../driver/cc1as_main.cpp
  ../driver/cc1gen_reproducer_main.cpp
  helloplugin.cpp
  DEPENDS
  intrinsics_gen
  ${support_plugins}
  GENERATE_DRIVER
  )

clang_target_link_libraries(clang-hello-plugin-test
  PRIVATE
  clangBasic
  clangCodeGen
  clangDriver
  clangFrontend
  clangFrontendTool
  clangSerialization
  )

if(WIN32 AND NOT CYGWIN)
  # Prevent versioning if the buildhost is targeting for Win32.
else()
  set_target_properties(clang-hello-plugin-test PROPERTIES VERSION ${CLANG_EXECUTABLE_VERSION})
endif()

# Support plugins.
if(CLANG_PLUGIN_SUPPORT)
  export_executable_symbols_for_plugins(clang-hello-plugin-test)
endif()

add_dependencies(clang-hello-plugin-test clang-resource-headers)
