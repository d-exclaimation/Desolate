//
//  Int+Nanoseconds.swift
//  Desolate
//
//  Created by d-exclaimation on 6:03 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Int {
    /// Self seconds into a Nanosecond unit
    var seconds: Nanoseconds { milliseconds * 1000 }

    /// Self milliseconds into a Nanosecond unit
    var milliseconds: Nanoseconds { microseconds * 1000 }

    /// Self microseconds into a Nanosecond unit
    var microseconds: Nanoseconds { nanoseconds * 1000 }

    /// Self nanoseconds into a Nanosecond unit
    var nanoseconds: Nanoseconds { UInt64(self) }
}