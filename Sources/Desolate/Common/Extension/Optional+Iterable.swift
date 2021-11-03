//
//  Optional+Iterable.swift
//  Desolate
//
//  Created by d-exclaimation on 4:15 AM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Optional {

    /// Map the wrapped value of the optional
    func map<U>(_ fn: @escaping (Wrapped) -> U) -> Optional<U> {
        switch self {
        case .none:
            return .none
        case .some(let wrapped):
            return .some(fn(wrapped))
        }
    }

    /// Map the wrapped value of the optional and flatten it
    func flatMap<U>(_ fn: @escaping (Wrapped) -> Optional<U>) -> Optional<U> {
        switch self {
        case .none:
            return .none
        case .some(let wrapped):
            return fn(wrapped)
        }
    }
}