//
//  Jet+Interface.swift
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

    /// Create a new Jet from a upstream AsyncSequence
    ///
    /// ```swift
    /// let (nozzle, desolate) = Nozzle<Int>.desolate()
    /// let jet = Jet.upstream(nozzle)
    /// ```
    ///
    /// - Parameter stream: Upstream AsyncSequence
    /// - Returns: a new Jet using AsyncSequence
    public static func upstream<Upstream: AsyncSequence>(_ stream: Upstream) -> Jet<Element> where Upstream.Element == Element {
        let (jet, desolate) = Jet<Element>.desolate()
        Task.detached {
            for try await each in stream {
                await desolate.task(with: .next(each))
            }
            await desolate.task(with: .complete)
        }
        return jet
    }

    /// End the Jet
    public func end() {
        desolate.tell(with: .complete)
    }
}