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
    let lock = NSConditionLock(condition: 0)
    var result: Result<Success, CollapsedBridge> = .failure(.idle)

    func closure() async {
        lock.lock(whenCondition: 0)
        let res = await operation()
        result = .success(res)
        lock.unlock(withCondition: 0)
    }

    switch bridge(timeout: dur, for: closure) {
    case .success(_):
        return result
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
    let lock = NSConditionLock(condition: 0)
    var result: Result<Success, CollapsedBridge> = .failure(.idle)

    func closure() async {
        lock.lock(whenCondition: 0)
        switch await operation() {
        case .success(let res):
            result = .success(res)
            break
        case .failure(let error):
            result = .failure(.failure(error: error))
            break
        }
        lock.unlock(withCondition: 0)
    }

    switch bridge(timeout: dur, for: closure) {
    case .success(_):
        return result
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
    let lock = NSConditionLock(condition: 0)
    var result: Result<Success, CollapsedBridge> = .failure(.idle)

    func closure() async throws {
        lock.lock(whenCondition: 0)
        do {
            let res = try await operation()
            result = .success(res)
        } catch {
            result = .failure(.failure(error: error))
        }
        lock.unlock(withCondition: 0)
    }

    switch bridge(timeout: dur, throw: closure) {
    case .success(_):
        return result
    case .failure(let err):
        return .failure(err)
    }
}