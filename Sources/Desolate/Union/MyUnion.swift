//
//  MyUnion.swift
//  Desolate
//
//  Created by d-exclaimation on 3:06 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

protocol MyUnion {}

struct Union0: MyUnion {
    func call() {}
}
struct Union1: MyUnion {
    var hello: String {
        ""
    }
}
struct Union2: MyUnion {
    let num: Int = 0
}

fileprivate func match(u: MyUnion) {
    switch u {
    case let u0 as Union0:
        u0.call()
        break
    case let u1 as Union1:
        let _ = u1.hello
        break
    case let u2 as Union2:
        let _ = u2.num
        break
    default:
        break
    }
}