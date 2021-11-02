//
//  Conduit.swift
//  Desolate
//
//  Created by d-exclaimation on 4:41 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// Asynchronous function that always successfully return a value
public typealias Async<ReturnType> = () async -> ReturnType

/// Asynchronous function that can fail
public typealias AsyncFailable<ReturnType> = () async throws -> ReturnType

/// Bridge a async block to a non async one and pass the result
///
/// - Parameters:
///   - dur: Timeout duration.
///   - operation: Asynchronous function that return the proper value
/// - Returns: Result of the Successful value or a BridgeError
public func conduit<Success>(timeout dur: TimeInterval, for operation: @escaping Async<Success>) -> Result<Success, CollapsedBridge> {
    let capsule = MutexCapsule<Success>()

    func closure() async {
        let res = await operation()
        await capsule.task(with: res)
    }

    switch bridge(timeout: dur, for: closure) {
    case .success(_):
        if let succ = try? capsule.acquire() {
            return .success(succ)
        }
        return .failure(.timeout)
    case .failure(let err):
        return .failure(err)
    }
}

/// Bridge a async block to a non async one and pass the result
///
/// - Parameters:
///   - dur: Timeout duration.
///   - operation: Asynchronous function that return another Result
/// - Returns: Flatten Result with transformed error
public func conduit<Success, Failure: Error>(timeout dur: TimeInterval, under operation: @escaping Async<Result<Success, Failure>>) -> Result<Success, CollapsedBridge> {
    let capsule = MutexCapsule<Result<Success, CollapsedBridge>>()

    func closure() async {
        switch await operation() {
        case .success(let res):
            await capsule.task(with: .success(res))
            break
        case .failure(let error):
            await capsule.task(with: .failure(.failure(error: error)))
            break
        }
    }

    switch bridge(timeout: dur, for: closure) {
    case .success(_):
        if let res = try? capsule.acquire() {
            return res
        }
        return .failure(.timeout)
    case .failure(let err):
        return .failure(err)
    }
}

/// Bridge a async block to a non async one and pass the result
///
/// - Parameters:
///   - dur: Timeout duration.
///   - operation: Asynchronous function that return the proper value or throw error
/// - Returns: Result of the Successful value or a BridgeError
public func conduit<Success>(timeout dur: TimeInterval, for operation: @escaping AsyncFailable<Success>) -> Result<Success, CollapsedBridge> {
    let capsule = MutexCapsule<Result<Success, CollapsedBridge>>()

    func closure() async throws {
        do {
            let res = try await operation()
            await capsule.task(with: .success(res))
        } catch {
            await capsule.task(with: .failure(.failure(error: error)))
        }
    }

    switch bridge(timeout: dur, throw: closure) {
    case .success():
        if let res = try? capsule.acquire() {
            return res
        }
        return .failure(.timeout)
    case .failure(let err):
        return .failure(err)
    }
}
