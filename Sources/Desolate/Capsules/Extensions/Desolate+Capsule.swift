//
//  Desolate+Capsule.swift
//  Desolate
//
//  Created by d-exclaimation on 9:26 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Desolate where ActorType: CapsuleInterface  {

    /// Get and wait from am AsyncCapsule
    public func get(timeout: TimeInterval = 5.0) throws -> ActorType.Value where ActorType.MessageType == AsyncCapsule<ActorType.Value>.Intent {
        let res = conduit(timeout: timeout) { try await ask { .get(ref: $0) } }
        switch res {
        case .success(let val):
            return val
        case .failure(let err):
            throw err
        }
    }

    /// Get asynchronous from an AsyncCapsule
    public func get() async throws -> ActorType.Value where ActorType.MessageType == AsyncCapsule<ActorType.Value>.Intent {
        try await ask { .get(ref: $0) }
    }

    /// Set and not wait from an AsyncCapsule
    public func set(_ newValue: ActorType.Value) where ActorType.MessageType == AsyncCapsule<ActorType.Value>.Intent {
        tell(with: .set(new: newValue))
    }

    /// Set asynchronous from an AsyncCapsule
    public func set(_ newValue: ActorType.Value) async where ActorType.MessageType == AsyncCapsule<ActorType.Value>.Intent {
        await task(with: .set(new: newValue))
    }

    /// Set using a mapping function from an AsyncCapsule
    public func set(using newSetter: @escaping (ActorType.Value) -> ActorType.Value) where ActorType.MessageType == AsyncCapsule<ActorType.Value>.Intent {
        tell(with: .apply(fn: newSetter))
    }

    /// Set asynchronous using a mapping function from an AsyncCapsule
    public func set(using newSetter: @escaping (ActorType.Value) -> ActorType.Value) async where ActorType.MessageType == AsyncCapsule<ActorType.Value>.Intent {
        await task(with: .apply(fn: newSetter))
    }
}