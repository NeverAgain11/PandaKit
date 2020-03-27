//
//  Approx.swift
//  Cassowary
//
//  Created by Tang.Nan on 2017/10/17.
//  Copyright © 2017年 nange. All rights reserved.
//


/// value type box for performance optimization
/// sometimes we may need to wrap Struct into Class to avoid frequence copy operation

final class RefBox<Type> {
    var value: Type
    init(_ value: Type) {
        self.value = value
    }
}

@inline(__always) func approx(a: Double, b: Double) -> Bool {
    let epsilon = 1.0e-6
    return fabs(a-b) < epsilon
}

@inline(__always) func nearZero(_ a: Double) -> Bool {
    return approx(a: a, b: 0)
}
