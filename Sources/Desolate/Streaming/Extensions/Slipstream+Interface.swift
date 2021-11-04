//
//  Slipstream+Interface.swift
//  Desolate
//
//  Created by d-exclaimation on 7:26 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Jet {
    /// Create a new Jet and give back its inner desolate
    ///
    /// - Returns: The Jet and its inner Dam
    public static func desolate() -> (Jet<Element>, Desolate<Pipeline>) {
        let jet = Jet<Element>.init()
        return (jet, jet.desolate)
    }

    /// End the Jet
    public func end() {
        desolate.tell(with: .complete)
    }
}