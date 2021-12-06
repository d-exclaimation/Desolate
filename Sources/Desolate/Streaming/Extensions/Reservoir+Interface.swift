//
//  Reservoir+Interface.swift
//  Desolate
//
//  Created by d-exclaimation on 3:22 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Reservoir {
    /// Create or collect an existing Source from the Reservoir
    ///
    /// - Parameter key: Key used to ID the Source
    /// - Returns: A new Source or an existing one
    public func source(for key: Key) async -> Source<Element> {
        let supply = await desolate.ask {
            .acquire(key: key, ref: $0)
        }
        return .init(supply)
    }

    /// Create a new Nozzle from a new or existing Source in the Reservoir
    ///
    /// - Parameter key: Key used to ID the Source
    /// - Returns: A new Nozzle from the Source
    public func nozzle(for key: Key) async -> Nozzle<Element> {
        await desolate.ask {
            .collect(key: key, ref: $0)
        }
    }

    /// Terminate and shutdown operation of a Source stream
    ///
    /// - Parameter key: Key used to ID the source
    public func close(for key: Key) {
        desolate.tell(with: .deallocate(key: key))
    }

    /// Produce and discharge an element into a Source through this Reservoir using the key.
    ///
    /// **Non-blocking**: Code will execute even before fully emitted
    ///
    /// - Parameters:
    ///   - key: Key for the Source
    ///   - value: Value being produced and discharge
    public func emit(for key: Key, _ value: Element) {
        desolate.tell(with: .dispatch(key: key, value))
    }

    /// Produce and discharge an element into a Source through this Reservoir using the key.
    ///
    /// **Awaitable**: If awaited, will wait for value to be emitted to Source
    ///
    /// - Parameters:
    ///   - key: Key for the Source
    ///   - value: Value being produced and discharge
    public func dispatch(for key: Key, _ value: Element) async {
        await desolate.task(with: .dispatch(key: key, value))
    }
}

extension Reservoir where Key == String, Element == Any {
    /// Reservoir with Any element and generic string key
    public static func any() -> Reservoir<Key, Any> {
        self.init(key: String.self, element: Any.self)
    }
}