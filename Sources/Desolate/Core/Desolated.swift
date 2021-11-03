//
//  Desolated.swift
//  Desolate
//
//  Created by d-exclaimation on 8:30 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

@propertyWrapper
struct Desolated<Value> {

    private var innerHook: Desolate<AsyncCapsule<Value>>
    private let timeout: TimeInterval
    private let cache: InMemoryCache<Value>

    var wrappedValue: Value {
        get { cache.cache { try innerHook.get() } }
        set { innerHook.set(newValue) }
    }

    init(wrappedValue: Value) {
        innerHook = pocket { wrappedValue }
        timeout = 5.0
        cache = InMemoryCache<Value> { wrappedValue }
    }

    init(wrappedValue: Value, timeout tm: TimeInterval, fallback fb: @escaping () -> Value) {
        innerHook = pocket { wrappedValue }
        timeout = tm
        cache = InMemoryCache<Value> { wrappedValue }
    }
}
