//
//  Bridge.swift
//  Desolate
//
//  Created by d-exclaimation on 9:50 AM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// Asynchronous function that doesn't return a value
public typealias AsyncFunction = () async -> Void

/// Asynchronous function that doesn't return a value but throws an error
public typealias AsyncThrowFunction = () async throws -> Void

/// Bridge the async blocks with a non async one, allowing async code
/// to be executed top level
///
/// **Blocking call**
///
/// ```
/// bridge {
///     async let res = asyncFunction()
///     await print(res)
/// }
/// ```
///
/// - Parameter operation: Asynchronous function closure.
public func bridge(for operation: @escaping AsyncFunction) {
    let group = DispatchGroup()
    group.enter()
    Task {
        await operation()
        group.leave()
    }
    group.wait()
}

/// Bridge the async blocks with a non async one, allowing async throwing code
/// to be executed top level
///
/// **Blocking call**
///
/// ```
/// bridge {
///     try await asyncFunction()
/// }
/// ```
///
/// - Parameter operation: Asynchronous throwing function closure.
public func bridge(throw operation: @escaping AsyncThrowFunction) {
    let group = DispatchGroup()
    group.enter()
    Task {
        try await operation()
        group.leave()
    }
    group.wait()
}

/// Bridge the async blocks with a non async one, allowing async code
/// to be executed top level within a timeout
///
/// **Blocking throwing call**
///
/// ```
/// let timeout = DispatchTime.now() + DispatchTimeInterval.seconds(1)
/// try bridge(timeout: timeout) {
///     async let res = asyncFunction()
///     await print(res)
/// }
/// ```
///
/// - Parameter operation: Asynchronous function closure.
public func bridge(timeout: DispatchTime, for operation: @escaping AsyncFunction) -> Result<Void, BridgeError> {
    let group = DispatchGroup()
    group.enter()
    Task {
        await operation()
        group.leave()
    }
    let res = group.wait(timeout: timeout)
    switch res {
    case .success:
        return .success(())
    case .timedOut:
        return .failure(BridgeError.timeout)
    }
}


/// Bridge the async blocks with a non async one, allowing async code
/// to be executed top level within a timeout
///
/// **Blocking throwing call**
///
/// ```
/// let timeout = DispatchTime.now() + DispatchTimeInterval.seconds(1)
/// try bridge(timeout: timeout) {
///     async let res = asyncFunction()
///     await print(res)
/// }
/// ```
///
/// - Parameter operation: Asynchronous function closure.
public func bridge(timeout: DispatchTime, throw operation: @escaping AsyncThrowFunction) -> Result<Void, BridgeError> {
    let group = DispatchGroup()
    group.enter()
    Task.init(priority: nil) {
        try await operation()
        group.leave()
    }
    let res = group.wait(timeout: timeout)
    switch res {
    case .success:
        return .success(())
    case .timedOut:
        return .failure(BridgeError.timeout)
    }
}

/// Bridge the async blocks with a non async one, allowing async code
/// to be executed top level within a timeout
///
/// **Blocking throwing call**
///
/// ```
/// let timeout = DispatchTime.now() + DispatchTimeInterval.seconds(1)
/// try bridge(timeout: timeout) {
///     async let res = asyncFunction()
///     await print(res)
/// }
/// ```
///
/// - Parameter operation: Asynchronous function closure.
public func bridge(priority: TaskPriority?, timeout: DispatchTime, throw operation: @escaping AsyncThrowFunction) -> Result<Void, BridgeError> {
    let group = DispatchGroup()
    group.enter()
    Task.init(priority: priority) {
        try await operation()
        group.leave()
    }
    let res = group.wait(timeout: timeout)
    switch res {
    case .success:
        return .success(())
    case .timedOut:
        return .failure(BridgeError.timeout)
    }
}

/// Dispatch an async function to be executed on another task from a non async function.
///
/// - Parameter operation: Asynchronous function closure.
public func dispatch(for operation: @escaping AsyncFunction) {
    Task {
        await operation()
    }
}

/// Dispatch an async throwing function to be executed on another task from non async function.
///
/// - Parameter operation: Asynchronous throwing function closure.
public func dispatch(throw operation: @escaping AsyncThrowFunction) {
    Task {
        try await operation()
    }
}

