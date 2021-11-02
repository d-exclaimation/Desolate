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
//
//    static subscript<T>(
//            _enclosingInstance instance: T,
//            wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
//            storage storageKeyPath: ReferenceWritableKeyPath<T, Self>
//    ) -> Value {
//        get {
//            let hook: Desolate<StateHook<Value>> = instance[keyPath: storageKeyPath].innerHook
//            let timeout: TimeInterval = instance[keyPath: storageKeyPath].timeout
//            let fallback: () -> Value = instance[keyPath: storageKeyPath].fallback
//            let res = conduit(timeout: timeout) {
//                try await hook.ask(timeout: timeout) { .get(ref: $0)  }
//            }
//            switch res {
//            case .success(let val):
//                return val
//            case .failure(_):
//                return fallback()
//            }
//
//        } set {
//            let hook: Desolate<StateHook<Value>> = instance[keyPath: storageKeyPath].innerHook
//            hook.tell(with: .set(new: newValue))
//        }
//    }

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
