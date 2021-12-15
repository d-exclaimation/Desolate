//
//  Source+AsynSequence.swift
//  Desolate
//
//  Created by d-exclaimation on 6:31 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//


import Foundation

extension Source: AsyncSequence {
    /// Create an async iterator out of ``Desolate/Nozzle`` from this ``Desolate/Source``
    public func makeAsyncIterator() -> Nozzle<Element>.Iterator {
        .init(nozzle: nozzle())
    }
}
