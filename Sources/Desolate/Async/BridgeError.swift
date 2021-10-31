//
//  BridgeError.swift
//  Desolate
//
//  Created by d-exclaimation on 12:45 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

public enum BridgeError: Error {
    case functionFailed(error: Error)
    case timeout
    case idle
}