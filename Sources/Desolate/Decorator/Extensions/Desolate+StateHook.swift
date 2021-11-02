//
//  Desolate+StateHook.swift
//  Desolate
//
//  Created by d-exclaimation on 9:26 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Desolate where ActorType: CapsuleInterface  {

    /// Get and wait from am AsyncCapsule / Hook
    func get(timeout: TimeInterval = 5.0) -> ActorType.Value where ActorType.MessageType == HookIntent<ActorType.Value> {
        let res = conduit(timeout: timeout) { try await ask { .get(ref: $0) } }
        switch res {
        case .success(let val):
            return val
        case .failure(let err):
            fatalError(err.localizedDescription)
        }
    }

    /// Get asynchronous from an AsyncCapsule / Hook but return an optional
    func maybe(timeout: TimeInterval = 5.0) -> ActorType.Value? where ActorType.MessageType == HookIntent<ActorType.Value> {
        let res = conduit(timeout: timeout) { () -> ActorType.Value in
            try await ask { .get(ref: $0) }
        }
        switch res {
        case .success(let val):
            return val
        case .failure(_):
            return nil
        }
    }


    /// Get asynchronous from an AsyncCapsule / Hook
    func get() async -> ActorType.Value where ActorType.MessageType == HookIntent<ActorType.Value> {
        let res = try? await ask { .get(ref: $0) }
        guard let res = res else { fatalError() }
        return res
    }

    /// Set and not wait from an AsyncCapsule / Hook
    func set(_ newValue: ActorType.Value) where ActorType.MessageType == HookIntent<ActorType.Value> {
        tell(with: .set(new: newValue))
    }

    /// Set asynchronous from an AsyncCapsule / Hook
    func set(_ newValue: ActorType.Value) async where ActorType.MessageType == HookIntent<ActorType.Value> {
        await task(with: .set(new: newValue))
    }

    /// Set using a mapping function from an AsyncCapsule / Hook
    func set(using newSetter: @escaping (ActorType.Value) -> ActorType.Value) where ActorType.MessageType == HookIntent<ActorType.Value> {
        tell(with: .apply(fn: newSetter))
    }

    /// Set asynchronous using a mapping function from an AsyncCapsule / Hook
    func set(using newSetter: @escaping (ActorType.Value) -> ActorType.Value) async where ActorType.MessageType == HookIntent<ActorType.Value> {
        await task(with: .apply(fn: newSetter))
    }
}