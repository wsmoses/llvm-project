// RUN: clang-hello-plugin-test %s -o /dev/null -S | FileCheck %s

int myfunction() { return 0; }

// CHECK: [HelloPass] Found function: myfunction

