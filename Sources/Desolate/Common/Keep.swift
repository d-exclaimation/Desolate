//
//  Keep.swift
//  Desolate
//
//  Created by d-exclaimation on 12:13 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// Keep is a namespace for function in use for higher order function
public struct Keep {
    private init() {}

    /// A function for ignoring the right hand side value, usually in use in a higher order function fashion.
    public static func left<Left, Right>(_ lhs: Left, _ _: Right) -> Left { lhs }

    /// A function for ignoring the left hand side value, usually in use in a higher order function fashion.
    public static func right<Left, Right>(_ _: Left, _ rhs: Right) -> Right { rhs }

    /// A function for combined both left and right value into a tuple, usually in use in a higher order function fashion.
    public static func both<Left, Right>(_ lhs: Left, _ rhs: Right) -> (Left, Right) { (lhs, rhs) }
}