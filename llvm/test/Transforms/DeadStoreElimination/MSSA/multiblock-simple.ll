; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -basicaa -dse -enable-dse-memoryssa -S | FileCheck %s

target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"


define void @test2(i32* noalias %P) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    br i1 true, label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    br label [[BB3:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    br label [[BB3]]
; CHECK:       bb3:
; CHECK-NEXT:    store i32 0, i32* [[P:%.*]], align 4
; CHECK-NEXT:    ret void
;
  store i32 1, i32* %P
  br i1 true, label %bb1, label %bb2
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  store i32 0, i32* %P
  ret void
}

define void @test3(i32* noalias %P) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    store i32 0, i32* [[P:%.*]], align 4
; CHECK-NEXT:    br i1 true, label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    br label [[BB3:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    store i32 0, i32* [[P]], align 4
; CHECK-NEXT:    br label [[BB3]]
; CHECK:       bb3:
; CHECK-NEXT:    ret void
;
  store i32 0, i32* %P
  br i1 true, label %bb1, label %bb2
bb1:
  br label %bb3
bb2:
  store i32 0, i32* %P
  br label %bb3
bb3:
  ret void
}


define void @test7(i32* noalias %P, i32* noalias %Q) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:    br i1 true, label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    [[TMP1:%.*]] = load i32, i32* [[P:%.*]], align 4
; CHECK-NEXT:    br label [[BB3:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    br label [[BB3]]
; CHECK:       bb3:
; CHECK-NEXT:    store i32 0, i32* [[Q:%.*]], align 4
; CHECK-NEXT:    store i32 0, i32* [[P]], align 4
; CHECK-NEXT:    ret void
;
  store i32 1, i32* %Q
  br i1 true, label %bb1, label %bb2
bb1:
  load i32, i32* %P
  br label %bb3
bb2:
  br label %bb3
bb3:
  store i32 0, i32* %Q
  store i32 0, i32* %P
  ret void
}

define i32 @test22(i32* %P, i32* noalias %Q, i32* %R) {
; CHECK-LABEL: @test22(
; CHECK-NEXT:    store i32 2, i32* [[P:%.*]], align 4
; CHECK-NEXT:    store i32 3, i32* [[Q:%.*]], align 4
; CHECK-NEXT:    [[L:%.*]] = load i32, i32* [[R:%.*]], align 4
; CHECK-NEXT:    ret i32 [[L]]
;
  store i32 1, i32* %Q
  store i32 2, i32* %P
  store i32 3, i32* %Q
  %l = load i32, i32* %R
  ret i32 %l
}

define void @test9(i32* noalias %P) {
; CHECK-LABEL: @test9(
; CHECK-NEXT:    store i32 0, i32* [[P:%.*]], align 4
; CHECK-NEXT:    br i1 true, label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    br label [[BB3:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    ret void
; CHECK:       bb3:
; CHECK-NEXT:    store i32 0, i32* [[P]], align 4
; CHECK-NEXT:    ret void
;
  store i32 0, i32* %P
  br i1 true, label %bb1, label %bb2
bb1:
  br label %bb3
bb2:
  ret void
bb3:
  store i32 0, i32* %P
  ret void
}

; We cannot eliminate `store i32 0, i32* %P`, as it is read by the later load.
; Make sure that we check the uses of `store i32 1, i32* %P.1 which does not
; alias %P. Note that uses point to the *first* def that may alias.
define void @overlapping_read(i32* %P) {
; CHECK-LABEL: @overlapping_read(
; CHECK-NEXT:    store i32 0, i32* [[P:%.*]], align 4
; CHECK-NEXT:    [[P_1:%.*]] = getelementptr i32, i32* [[P]], i32 1
; CHECK-NEXT:    store i32 1, i32* [[P_1]], align 4
; CHECK-NEXT:    [[P_64:%.*]] = bitcast i32* [[P]] to i64*
; CHECK-NEXT:    [[LV:%.*]] = load i64, i64* [[P_64]], align 8
; CHECK-NEXT:    br i1 true, label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    br label [[BB3:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    br label [[BB3]]
; CHECK:       bb3:
; CHECK-NEXT:    store i32 2, i32* [[P]], align 4
; CHECK-NEXT:    ret void
;
  store i32 0, i32* %P
  %P.1 = getelementptr i32, i32* %P, i32 1
  store i32 1, i32* %P.1

  %P.64 = bitcast i32* %P to i64*
  %lv = load i64, i64* %P.64
  br i1 true, label %bb1, label %bb2
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  store i32 2, i32* %P
  ret void
}

define void @test10(i32* %P) {
; CHECK-LABEL: @test10(
; CHECK-NEXT:    store i32 0, i32* [[P:%.*]], align 4
; CHECK-NEXT:    br i1 true, label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    store i32 0, i32* [[P]], align 4
; CHECK-NEXT:    br label [[BB3:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    ret void
; CHECK:       bb3:
; CHECK-NEXT:    ret void
;
  store i32 0, i32* %P
  br i1 true, label %bb1, label %bb2
bb1:
  store i32 0, i32* %P
  br label %bb3
bb2:
  ret void
bb3:
  ret void
}


define void @test11() {
; CHECK-LABEL: @test11(
; CHECK-NEXT:    br i1 true, label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    br label [[BB3:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    ret void
; CHECK:       bb3:
; CHECK-NEXT:    ret void
;
  %P = alloca i32
  store i32 0, i32* %P
  br i1 true, label %bb1, label %bb2
bb1:
  store i32 0, i32* %P
  br label %bb3
bb2:
  ret void
bb3:
  ret void
}


define void @test12(i32* %P) {
; CHECK-LABEL: @test12(
; CHECK-NEXT:    br i1 true, label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    store i32 1, i32* [[P:%.*]], align 4
; CHECK-NEXT:    br label [[BB3:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    store i32 1, i32* [[P]], align 4
; CHECK-NEXT:    ret void
; CHECK:       bb3:
; CHECK-NEXT:    ret void
;
  store i32 0, i32* %P
  br i1 true, label %bb1, label %bb2
bb1:
  store i32 1, i32* %P
  br label %bb3
bb2:
  store i32 1, i32* %P
  ret void
bb3:
  ret void
}


define void @test13(i32* %P) {
; CHECK-LABEL: @test13(
; CHECK-NEXT:    br i1 true, label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    store i32 1, i32* [[P:%.*]], align 4
; CHECK-NEXT:    br label [[BB3:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    store i32 1, i32* [[P]], align 4
; CHECK-NEXT:    br label [[BB3]]
; CHECK:       bb3:
; CHECK-NEXT:    ret void
;
  store i32 0, i32* %P
  br i1 true, label %bb1, label %bb2
bb1:
  store i32 1, i32* %P
  br label %bb3
bb2:
  store i32 1, i32* %P
  br label %bb3
bb3:
  ret void
}
