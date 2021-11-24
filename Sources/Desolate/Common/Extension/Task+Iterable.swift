//
//  Task+Iterable.swift
//  Desolate
//
//  Created by d-exclaimation on 4:48 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Deferred {
    /// Mapping function
    public typealias MapFunc<U> = (Success) -> U

    /// Creates a new Task by applying a function to the successful result of this task.
    public func map<U>(_ fn: @escaping MapFunc<U>) -> Deferred<U> {
        deferred { fn(try await value) }
    }

    /// FlatMapping async function
    public typealias AsyncMapFunc<U> = (Success) async -> U

    /// Creates a new Task by applying a function to the successful result of this task, and returns the result of the function as the new task.
    public func flatMap<U>(_ fn: @escaping AsyncMapFunc<U>) -> Deferred<U> {
        deferred { await fn(try await value) }
    }

    /// FlatMapping function
    public typealias FlatMapFunc<U, F: Error> = (Success) -> Task<U, F>

    /// Creates a new Task by applying a function to the successful result of this task, and returns the result of the function as the new task.
    public func flatMap<U, F: Error>(_ transform: @escaping FlatMapFunc<U, F>) -> Deferred<U> {
        deferred { try await transform(try await value).value }
    }
}

fileprivate func deferred<U>(operation: @escaping AsyncFailable<U>) -> Deferred<U> {
    Task { try await operation() }
}