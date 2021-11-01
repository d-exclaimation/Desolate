//
//  CollapsedBridge.swift
//  Desolate
//
//  Created by d-exclaimation on 4:43 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// Collapsed Async to Sync bridge due to failures, timeouts or idles
public enum CollapsedBridge: Error {
    /// Async function thrown an error
    case failure(error: Error)

    /// Async function timed out
    case timeout

    /// Async function was never called
    case idle
}
