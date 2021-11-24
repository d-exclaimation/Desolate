//
//  AskableError.swift
//  Desolate
//
//  Created by d-exclaimation on 11:43 AM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// Delivery Custom Error type
public struct AskPatternError: Error {
    /// Retries
    var retries: Int

    /// Localized description for the error message
    var localizedDescription: String {
        "Didn't receive response within the allowed amount of retries / timeout, retries count: \(retries)"
    }
}
