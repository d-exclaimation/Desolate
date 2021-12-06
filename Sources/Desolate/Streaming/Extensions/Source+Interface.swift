//
//  Source+Interface.swift
//  Desolate
//
//  Created by d-exclaimation on 7:26 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Source {
    /// Create a new Source and give back its inner desolate
    ///
    /// ```swift
    /// ```
    ///
    /// - Returns: The Source and its inner Supply
    public static func desolate() -> (Source<Element>, Desolate<Supply>) {
        let source = Source<Element>.init()
        return (source, source.desolate)
    }

    /// Create a new Source from a upstream AsyncSequence
    ///
    /// ```swift
    /// let (nozzle, desolate) = Nozzle<Int>.desolate()
    /// let source = Source.upstream(nozzle)
    /// ```
    ///
    /// - Parameter stream: Upstream AsyncSequence
    /// - Returns: a new Source using AsyncSequence
    public static func upstream<Upstream: AsyncSequence>(_ stream: Upstream) -> Source<Element> where Upstream.Element == Element {
        let (source, desolate) = Source<Element>.desolate()
        Task.detached {
            for try await each in stream {
                await desolate.task(with: .next(each))
            }
            await desolate.task(with: .complete)
        }
        return source
    }

    /// End the Source
    public func end() {
        desolate.tell(with: .complete)
    }
}