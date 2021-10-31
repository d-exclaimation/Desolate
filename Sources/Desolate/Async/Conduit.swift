//
//  Conduit.swift
//  Desolate
//
//  Created by d-exclaimation on 1:00 PM.
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
public func conduit<Success>(timeout dur: DispatchTime, for operation: @escaping Async<Success>) -> Result<Success, BridgeError> {
    var result: Result<Success, BridgeError> = .failure(.idle)

    func closure() async {
        let res = await operation()
        result = .success(res)
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
public func conduit<Success, Failure: Error>(timeout dur: DispatchTime, under operation: @escaping Async<Result<Success, Failure>>) -> Result<Success, BridgeError> {
    var result: Result<Success, BridgeError> = .failure(.idle)

    func closure() async {
        switch await operation() {
        case .success(let res):
            result = .success(res)
            break
        case .failure(let error):
            result = .failure(.functionFailed(error: error))
            break
        }
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
public func conduit<Success>(timeout dur: DispatchTime, for operation: @escaping AsyncFailable<Success>) -> Result<Success, BridgeError> {
    var result: Result<Success, BridgeError> = .failure(.idle)

    func closure() async throws {
        do {
            let res = try await operation()
            result = .success(res)
        } catch {
            result = .failure(.functionFailed(error: error))
        }
    }

    switch bridge(timeout: dur, throw: closure) {
    case .success(_):
        return result
    case .failure(let err):
        return .failure(err)
    }
}


extension Task {
    /// Blocking-ly await a Task in the top level thread
    ///
    /// - Parameters:
    ///   - priority: TaskPriority used for the Task
    ///   - timeout: Timeout for waiting the result
    /// - Returns: A Result for Task's Success and BridgeError
    func wait(priority: TaskPriority? = nil, timeout: DispatchTime = DispatchTime.now() + DispatchTimeInterval.seconds(5)) -> Result<Success, BridgeError> {
        var result: Result<Success, BridgeError> = .failure(.idle)

        func closure() async throws {
            do {
                let res = try await value
                result = .success(res)
            } catch {
                result = .failure(.functionFailed(error: error))
            }
        }

        switch bridge(priority: priority, timeout: timeout, throw: closure) {
        case .success(_):
            return result
        case .failure(let err):
            return .failure(err)
        }
    }
}
