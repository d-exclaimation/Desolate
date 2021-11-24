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
    public func map<U>(_ fn: @escaping (Wrapped) -> U) -> Optional<U> {
        guard case .some(let wrapped) = self else {
            return .none
        }
        return .some(fn(wrapped))
    }

    /// Map the wrapped value of the optional and flatten it
    public func flatMap<U>(_ fn: @escaping (Wrapped) -> Optional<U>) -> Optional<U> {
        guard case .some(let wrapped) = self else {
            return .none
        }
        return fn(wrapped)
    }
}