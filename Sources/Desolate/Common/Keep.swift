//
//  Keep.swift
//  Desolate
//
//  Created by d-exclaimation on 12:13 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

public struct Keep {
    private init() {}

    // TODO: Add comment
    public static func left<Left, Right>(_ lhs: Left, _ _: Right) -> Left { lhs }
    public static func right<Left, Right>(_ _: Left, _ rhs: Right) -> Right { rhs }
    public static func both<Left, Right>(_ lhs: Left, _ rhs: Right) -> (Left, Right) { (lhs, rhs) }
}