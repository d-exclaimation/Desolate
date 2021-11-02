//
//  Expresions.swift
//  Desolate
//
//  Created by d-exclaimation on 2:27 AM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// Evaluate an expression / function immediately
public func returns<T>(_ fn: () -> T) -> T {
    fn()
}

/// Evaluate an async expression / function immediately
public func returns<T>(_ asyncFn: Async<T>) async -> T {
    await asyncFn()
}

/// Try to evaluate a throwable function immediately
public func tries<Success>(_ fn: () throws -> Success) -> Result<Success, Error> {
    Result { try fn() }
}

/// Try to evaluate an async throwable function immediately
public func tries<Success>(_ asyncFn: @escaping AsyncFailable<Success>) async -> Result<Success, Error> {
    await Task{ try await asyncFn() }.result
}

