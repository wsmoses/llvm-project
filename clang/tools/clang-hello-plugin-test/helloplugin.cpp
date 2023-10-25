//===-- helloplugin.cpp - Hello World test static link plugin ------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This is a test/example mechanism for statically adding functionality to Clang
// Codegen without requiring a fork of Clang.
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Support/LLVMDriver.h"

#include <functional>

using namespace llvm;

extern SmallVector<std::function<void(llvm::PassBuilder &)>>
    PassBuilderCallbacks;

class StaticPlugin {
public:
  StaticPlugin(std::function<void(llvm::PassBuilder &)> f) {
    PassBuilderCallbacks.push_back(f);
  }
};

class HelloPass final : public llvm::AnalysisInfoMixin<HelloPass> {
  friend struct llvm::AnalysisInfoMixin<HelloPass>;

private:
  static llvm::AnalysisKey Key;

public:
  using Result = llvm::PreservedAnalyses;

  Result run(llvm::Module &M, llvm::ModuleAnalysisManager &MAM) {
    for (auto &F : M)
      llvm::outs() << "[HelloPass] Found function: " << F.getName() << "\n";
    return PreservedAnalyses::all();
  }

  static bool isRequired() { return true; }
};

void HelloCallback(llvm::PassBuilder &PB) {
  PB.registerPipelineStartEPCallback(
      [](ModulePassManager &MPM, OptimizationLevel) {
        MPM.addPass(HelloPass());
      });
}

StaticPlugin P(HelloCallback);

extern int clang_main(int Argc, char **Argv,
                      const llvm::ToolContext &ToolContext);

int clang_hello_plugin_test_main(int Argc, char **Argv,
                                 const llvm::ToolContext &ToolContext) {
  return clang_main(Argc, Argv, ToolContext);
}
