//
//  Nozzle+Statics.swift
//  Desolate
//
//  Created by d-exclaimation on 6:40 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Nozzle {
    /// Create a Nozzle with no value and immediately finishes
    ///
    /// - Returns: Nozzle
    public static func empty() -> Nozzle<Element> {
        let desolate = Nozzle.Sink.create()
        defer {
            desolate.tell(with: nil)
        }
        return Nozzle.init(desolate)
    }

    /// Create a Nozzle with only 1 value and then finishes
    ///
    /// - Parameter just: The only value given
    /// - Returns: Nozzle
    public static func single(_ just: Element) -> Nozzle<Element> {
        let desolate = Nozzle.Sink.create()
        defer {
            Task.init {
                await desolate.task(with: just)
                await desolate.task(with: nil)
            }
        }
        return Nozzle.init(desolate)
    }

    /// Create a Nozzle with multiple finite value then finishes
    ///
    /// - Parameter elements: Finite elements
    /// - Returns: Nozzle
    public static func of(_ elements: Element...) -> Nozzle<Element> {
        let desolate = Nozzle.Sink.create()
        defer {
            Task.init {
                for element in elements {
                    await desolate.task(with: element)
                }
                await desolate.task(with: nil)
            }
        }
        return Nozzle.init(desolate)
    }


    /// Create a Nozzle from an Array of item and then finishes
    ///
    /// - Parameter elements: Array of elements
    /// - Returns: Nozzle
    public static func array(_ elements: [Element]) -> Nozzle<Element> {
        let desolate = Nozzle.Sink.create()
        defer {
            Task.init {
                for element in elements {
                    await desolate.task(with: element)
                }
                await desolate.task(with: nil)
            }
        }
        return Nozzle.init(desolate)
    }

    /// Create a Nozzle from a Desolated current, and give both
    ///
    /// - Returns: A Nozzle and its Desolated current
    public static func desolate() -> (Nozzle<Element>, Desolate<Sink>) {
        let desolate = Nozzle.Sink.create()
        return (Nozzle.init(desolate), desolate)
    }

    /// Nozzle's Pipe for adding values into Nozzle dynamically
    public struct Pipe: Sendable {
        internal let sink: Desolate<Sink>

        /// Emit a value into the pipe and to the Nozzle
        public func emit(_ element: Element) async {
            await sink.task(with: element)
        }

        /// End the data current, prevent any more values to be emitted
        public func close() async {
            await sink.task(with: .none)
        }
    }

    /// Builder function
    public typealias Builder = (Pipe) async -> Void

    /// Convenience initializer using the Builder
    ///
    /// ```swift
    /// let nozzle = Nozzle { pipe async in
    ///     for i in 0...10 {
    ///         await Task.sleep(1000)
    ///         await pipe.emit(i)
    ///     }
    ///     await pipe.close()
    /// }
    /// ```
    ///
    /// - Parameter builder: Builder function
    public init(_ builder: @escaping Builder) {
        let sink = Sink.create()
        let pipe = Pipe(sink: sink)
        defer {
            Task.init {
                await builder(pipe)
            }
        }
        self.init(sink)
    }
}