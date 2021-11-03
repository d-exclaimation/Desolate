//
//  Deferred.swift
//  Desolate
//
//  Created by d-exclaimation on 4:01 AM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

public typealias Deferred<Value> = Task<Value, Error>

public typealias Job = Task<Void, Never>

public typealias UDeferred<Value> = Task<Value, Never>