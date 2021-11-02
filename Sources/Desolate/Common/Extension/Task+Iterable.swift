//
//  Task+Iterable.swift
//  Desolate
//
//  Created by d-exclaimation on 4:48 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Task {

    /// Mapping function
    typealias MapFunc<U> = (Success) -> U

    /// Creates a new Task by applying a function to the successful result of this task.
    func map<U>(_ mapper: @escaping MapFunc<U>) -> Task<U, Error> {
        task { mapper(try await value) }
    }

    /// FlatMapping async function
    typealias AsyncMapFunc<U> = (Success) async -> U

    /// Creates a new Task by applying a function to the successful result of this task, and returns the result of the function as the new task.
    func flatMap<U>(_ mapper: @escaping AsyncMapFunc<U>) -> Task<U, Error> {
        task { await mapper(try await value) }
    }

    /// FlatMapping function
    typealias FlatMapFunc<U, F: Error> = (Success) -> Task<U, F>

    /// Creates a new Task by applying a function to the successful result of this task, and returns the result of the function as the new task.
    func flatMap<U, F: Error>(_ mapper: @escaping FlatMapFunc<U, F>) -> Task<U, Error> {
        task { try await mapper(try await value).value }
    }
}

fileprivate func task<U>(operation: @escaping AsyncFailable<U>) -> Task<U, Error> {
    Task { try await operation() }
}