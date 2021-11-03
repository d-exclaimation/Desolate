//
//  Deferred.swift
//  Desolate
//
//  Created by d-exclaimation on 4:01 AM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// A unit of value for concurrency, non-blocking cancellable future, or a Job / Task with result
public typealias Deferred<Value> = Task<Value, Error>

/// A concurrent job, doesn't fail, doesn't return anything
public typealias Job = Task<Void, Never>


/// Infallible Deferred
public typealias UDeferred<Value> = Task<Value, Never>