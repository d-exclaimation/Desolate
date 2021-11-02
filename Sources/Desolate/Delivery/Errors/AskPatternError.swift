//
//  AskableError.swift
//  Desolate
//
//  Created by d-exclaimation on 11:43 AM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// Delivery Custom Error type
/// that specify the timeout duration and error message
public struct AskPatternError: Error {
    /// Timeout duration / interval
    var timeout: TimeInterval

    /// Localized description for the error message
    var localizedDescription: String {
        NSError(
           domain: "Desolate.Delivery",
           code: 200,
           userInfo: [
               "Error reason": "Ask pattern timeout",
               "Timeout duration in seconds": timeout
           ]
        ).localizedDescription
    }
}
