//===--- RangeDiagnostics.swift -------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
// RUN: %target-parse-verify-swift

import StdlibUnittest

func typeInference_Comparable<C : Comparable>(v: C) {
  do {
    var range = v..<v
    expectType(Range<C>.self, &range)
  }
  _ = v...v // FIXME: swift-3-indexing-model: shouldn't compile.
}

func typeInference_Strideable<S : Strideable>(v: S) {
  do {
    var range = v..<v
    expectType(RangeOfStrideable<S>.self, &range)
  }
  do {
    var range = v...v
    expectType(ClosedRangeOfStrideable<S>.self, &range)
  }
}

// FIXME: swift-3-indexing-model: decide what to do with the following QoI.
// The previous implementation was imposing an ABI burden.

// The point of this test is to check that we don't allow indexing
// Range<Int> et al with Int outside a generic context, to prevent the
// problem that r[0] will be invalid when 0 is not contained int he
// range.

// Many of these error messages are terrible.  If the test starts
// failing because the error message improves, obviously, update the
// test!

let r0 = 10..<100        
let r1 = UInt(10)..<100
let r2 = 10...100
let r3 = UInt(10)...100
r0[0]       // expected-error {{ambiguous use of 'subscript'}}
r1[UInt(0)] // expected-error {{ambiguous use of 'subscript'}}
r1[0]       // expected-error {{ambiguous use of 'subscript'}}
r2[0]       // expected-error {{ambiguous use of 'subscript'}}
r3[0]       // expected-error {{ambiguous use of 'subscript'}}
r0[0..<4]   // expected-error {{cannot subscript a value of type 'Range<Int>' with an index of type 'Range<Int>'}}
r1[0..<4]   // expected-error {{cannot subscript a value of type 'Range<UInt>' with an index of type 'Range<Int>'}}
r2[0..<4]   // expected-error {{cannot subscript a value of type 'Range<Int>' with an index of type 'Range<Int>'}}
r3[0..<4]   // expected-error {{cannot subscript a value of type 'Range<UInt>' with an index of type 'Range<Int>'}}
(10..<100)[0]           // expected-error {{ambiguous use of 'subscript'}}
(UInt(10)...100)[0..<4] // expected-error {{cannot subscript a value of type 'Range<UInt>' with an index of type 'Range<Int>'}}

