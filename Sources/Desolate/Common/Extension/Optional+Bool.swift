//
//  Optional+Bool.swift
//  Desolate
//
//  Created by d-exclaimation on 4:19 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Optional {
    /// Check whether an Optional is defined
    var isSome: Bool {
        if case .none = self {
            return false
        }

        return true
    }

    /// Check whether an Optional is not defined
    var isNone: Bool { !isSome }
}