//
//  AskableError.swift
//  Desolate
//
//  Created by d-exclaimation on 11:43 AM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// AskPattern Custom Error type
/// that specify the timeout duration and error message
public struct AskPatternError: Error {
    /// Timeout duration / interval
    var timeout: TimeInterval

    /// Localized description for the error message
    var localizedDescription: String {
        NSError(
           domain: "Desolate.AskPattern",
           code: 200,
           userInfo: [
               "Error reason": "Ask pattern timeout",
               "Timeout duration in seconds": timeout
           ]
        ).localizedDescription
    }
}
