//
//  InMemoryCache.swift
//  Desolate
//
//  Created by d-exclaimation on 1:55 AM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// In Memory Cache implementation
internal class InMemoryCache<Value> {
    var last: Value

    init(_ fn: () -> Value) {
        last = fn()
    }

    /// Cache if any otherwise use the cached value
    func cache(_ val: Value?) -> Value {
        guard let val = val else { return last }
        last = val
        return last
    }

    /// Cache if any otherwise use the cached value
    func cache(_ fn: @escaping () throws -> Value) -> Value {
        guard case .success(let res) = Result(catching: fn) else { return last }
        return res
    }
}
