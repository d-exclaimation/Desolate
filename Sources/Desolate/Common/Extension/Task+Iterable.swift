//
//  Task+Iterable.swift
//  Desolate
//
//  Created by d-exclaimation on 4:48 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Deferred {

    /// Creates a new Task by applying a function to the successful result of this task.
    public func map<U>(_ fn: @escaping @Sendable (Success) -> U) -> Deferred<U> {
        Deferred<U> { try await fn(value) }
    }


    /// Creates a new Task by applying a function to the successful result of this task, and returns the result of the function as the new task.
    public func flatMap<U>(_ fn: @escaping @Sendable (Success) async throws -> U) -> Deferred<U> {
        Deferred<U> { try await fn(try await value) }
    }


    /// Creates a new Task by applying a function to the successful result of this task, and returns the result of the function as the new task.
    public func flatMap<U, F: Error>(_ transform: @escaping @Sendable (Success) -> Task<U, F>) -> Deferred<U> {
        Deferred<U> { try await transform(try await value).value }
    }
}

