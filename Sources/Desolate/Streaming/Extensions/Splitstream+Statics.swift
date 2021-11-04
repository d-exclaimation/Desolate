//
//  Splitstream+Statics.swift
//  Desolate
//
//  Created by d-exclaimation on 2:09 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Slipstream {
    /// Source initializer with a Receiver
    ///
    /// - Returns: the Source and a Receiver to push value
    public static func receiver() -> (Slipstream<Element>, Receiver<Element>) {
        let source: Slipstream<Element> = Slipstream<Element>()
        let receiver: Receiver<Element> = source.desolate.ref { .give($0) }
        return (source, receiver)
    }

    /// Source initializer with a Desolate
    ///
    /// - Returns: the Source and the Desolate
    public static func desolate() -> (Slipstream<Element>, Desolate<Hub>) {
        let source: Slipstream<Element> = Slipstream<Element>()
        return (source, source.desolate)
    }
}

