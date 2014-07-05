//
//  mpz.swift
//  gmpint
//
//  Created by Dan Kogai on 7/5/14.
//  Copyright (c) 2014 Dan Kogai. All rights reserved.
//

import Darwin
/// initializes any struct
func initStruct<T>() -> T {
    var ptr = UnsafePointer<T>.alloc(sizeof(T.self))
    var val = ptr.memory
    ptr.destroy()
    return val
}
/// Big Integer by GMP
class GMPInt {
    var mpz:mpz_t = initStruct()
    init(){ gmpint_seti(&mpz, 0)}
    init(_ mpz:mpz_t) { self.mpz = mpz }
    init(_ s:String, base:Int=10){
        s.withCString {
            gmpint_sets(&self.mpz, $0, CInt(base))
        }
    }
    // to work around the difference between
    // GMP's 32-bit int and OS X's 64-bit int,
    // we use string even for ints
    convenience init(_ i:Int) { self.init(String(i)) }
    deinit {
        gmpint_unset(&mpz)
    }
}
extension GMPInt: Printable {
    func toString(base:Int=10)->String {
        let cstr = gmpint2str(&mpz, CInt(base))
        let result = String.fromCString(cstr)
        free(cstr)
        return result
    }
    var description:String { return toString() }
}
extension GMPInt: Equatable, Comparable {}
@infix func <(lhs:GMPInt, rhs:GMPInt)->Bool {
    return gmpint_cmp(&lhs.mpz, &rhs.mpz) < 0
}
@infix func ==(lhs:GMPInt, rhs:GMPInt)->Bool {
    return gmpint_cmp(&lhs.mpz, &rhs.mpz) == 0
}
/// unary +
@prefix func +(op:GMPInt) -> GMPInt { return op }
/// unary -
@prefix func -(op:GMPInt) -> GMPInt {
    var rop = GMPInt()
    gmpint_negz(&rop.mpz, &op.mpz)
    return rop
}
/// abs
func abs(op:GMPInt)->GMPInt {
    var rop = GMPInt()
    gmpint_absz(&rop.mpz, &op.mpz)
    return rop
}
/// <<, left bit shift
@infix func <<(lhs:GMPInt, bits:UInt) -> GMPInt {
    var rop = GMPInt()
    gmpint_lshift(&rop.mpz, &lhs.mpz, bits)
    return rop
}
/// <<=
@assignment func <<=(inout lhs:GMPInt, bits:UInt) -> GMPInt {
    gmpint_lshift(&lhs.mpz, &lhs.mpz, bits)
    return lhs
}
/// >>, right bit shift
@infix func >>(lhs:GMPInt, bits:UInt) -> GMPInt {
    var rop = GMPInt()
    gmpint_rshift(&rop.mpz, &lhs.mpz, bits)
    return rop
}
/// >>=
@assignment func >>=(inout lhs:GMPInt, bits:UInt) -> GMPInt {
    gmpint_rshift(&lhs.mpz, &lhs.mpz, bits)
    return lhs
}
/// binary +
@infix func +(lhs:GMPInt, rhs:GMPInt) -> GMPInt {
    var rop = GMPInt()
    gmpint_addz(&rop.mpz, &lhs.mpz, &rhs.mpz)
    return rop
}
@infix func +(lhs:GMPInt, rhs:Int) -> GMPInt {
    return lhs + GMPInt(rhs)
}
@infix func +(lhs:Int, rhs:GMPInt) -> GMPInt {
    return GMPInt(lhs) + rhs
}
/// +=
@assignment func +=(inout lhs:GMPInt, rhs:GMPInt) -> GMPInt {
    gmpint_addz(&lhs.mpz, &lhs.mpz, &rhs.mpz)
    return lhs
}
@assignment func +=(inout lhs:GMPInt, rhs:Int) -> GMPInt {
    lhs += GMPInt(rhs)
    return lhs
}
/// binary -
@infix func -(lhs:GMPInt, rhs:GMPInt) -> GMPInt {
    var rop = GMPInt()
    gmpint_subz(&rop.mpz, &lhs.mpz, &rhs.mpz)
    return rop
}
@infix func -(lhs:GMPInt, rhs:Int) -> GMPInt {
    return lhs - GMPInt(rhs)
}
@infix func -(lhs:Int, rhs:GMPInt) -> GMPInt {
    return GMPInt(lhs) - rhs
}
/// -=
@assignment func -=(inout lhs:GMPInt, rhs:GMPInt) -> GMPInt {
    gmpint_subz(&lhs.mpz, &lhs.mpz, &rhs.mpz)
    return lhs
}
@assignment func -=(inout lhs:GMPInt, rhs:Int) -> GMPInt {
    lhs -= GMPInt(rhs)
    return lhs
}
/// binary *
@infix func *(lhs:GMPInt, rhs:GMPInt) -> GMPInt {
    var rop = GMPInt()
    gmpint_mulz(&rop.mpz, &lhs.mpz, &rhs.mpz)
    return rop
}
@infix func *(lhs:GMPInt, rhs:Int) -> GMPInt {
    return lhs * GMPInt(rhs)
}
@infix func *(lhs:Int, rhs:GMPInt) -> GMPInt {
    return GMPInt(lhs) * rhs
}
/// *=
@assignment func *=(inout lhs:GMPInt, rhs:GMPInt) -> GMPInt {
    gmpint_mulz(&lhs.mpz, &lhs.mpz, &rhs.mpz)
    return lhs
}
@assignment func *=(inout lhs:GMPInt, rhs:Int) -> GMPInt {
    lhs *= GMPInt(rhs)
    return lhs
}
/// /%, the divmod operator
operator infix /% { precedence 150 associativity left }
@infix func /%(lhs:GMPInt, rhs:GMPInt) -> (GMPInt, GMPInt) {
    var r = GMPInt(), q = GMPInt()
    // GMP + MacPorts + Yosemite has a bug that
    //   libdyld.dylib`stack_not_16_byte_aligned_error:
    // when rhs fits uint.
    // to work around it, we left-shift both sides with 64
    // then right shift the remainder w/ 64
    var n = lhs << 64
    var d = rhs << 64
    gmpint_divmodz(&r.mpz, &q.mpz, &n.mpz, &d.mpz)
    return (r, q >> 64)
}
@infix func /%(lhs:GMPInt, rhs:Int) -> (GMPInt, GMPInt) {
    return lhs /% GMPInt(rhs)
}
@infix func /%(lhs:Int, rhs:GMPInt) -> (GMPInt, GMPInt) {
    return GMPInt(lhs) /% rhs
}
/// binary /
@infix func /(lhs:GMPInt, rhs:GMPInt) -> GMPInt {
    return (lhs /% rhs).0
}
@infix func /(lhs:GMPInt, rhs:Int) -> GMPInt {
    return (lhs /% rhs).0
}
@infix func /(lhs:Int, rhs:GMPInt) -> GMPInt {
    return (lhs /% rhs).0
}
/// /=
@assignment func /=(inout lhs:GMPInt, rhs:GMPInt) -> GMPInt {
    lhs = lhs / rhs
    return lhs
}
@assignment func /=(inout lhs:GMPInt, rhs:Int) -> GMPInt {
    lhs = lhs / rhs
    return lhs
}
/// binary %
@infix func %(lhs:GMPInt, rhs:GMPInt) -> GMPInt {
    return (lhs /% rhs).1
}
@infix func %(lhs:GMPInt, rhs:Int) -> GMPInt {
    return (lhs /% rhs).1
}
@infix func %(lhs:Int, rhs:GMPInt) -> GMPInt {
    return (lhs /% rhs).1
}
/// /=
@assignment func %=(inout lhs:GMPInt, rhs:GMPInt) -> GMPInt {
    lhs = lhs % rhs
    return lhs
}
@assignment func %=(inout lhs:GMPInt, rhs:Int) -> GMPInt {
    lhs = lhs % rhs
    return lhs
}
