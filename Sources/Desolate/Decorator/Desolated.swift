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
    private var timeout: TimeInterval
    private var fallback: () -> Value

    var wrappedValue: Value {
        get {
            print("Getter called")
            return innerHook.maybe() ?? fallback()
        } set {
            innerHook.set(newValue)
        }
    }

    init(wrappedValue: Value) {
        innerHook = hook { wrappedValue }
        timeout = 5.0
        fallback = {
            fatalError("No value given")
        }
    }

    init(wrappedValue: Value, timeout tm: TimeInterval, fallback fb: @escaping () -> Value) {
        innerHook = hook { wrappedValue }
        timeout = tm
        fallback = fb
    }
}
