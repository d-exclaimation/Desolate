//
//  AbstractDesolate+BaseActor.swift
//  Desolate
//
//  Created by d-exclaimation on 3:13 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension AbstractDesolate where Self: BaseActor {

    /// Given a AbstractDesolate conforms to a BaseActor,
    /// a complete desolate can be initialized using the static `new()` method.
    ///
    /// ```swift
    /// actor Logger: AbstractBehavior, BaseActor {
    ///     var status: Signal = .running
    ///
    ///     func onMessage(msg: String) async -> Signal {
    ///         print("[\(Date().ISO8601Format())]: \(msg)")
    ///         return .running
    ///     }
    ///
    ///     init() {}
    /// }
    ///
    /// let desolate: Desolate<Logger> = Logger.new()
    ///
    /// desolate.tell(with: "Hello")
    /// ```
    ///
    /// - Returns: A complete Desolate
    public static func new() -> Desolate<Self> { Desolate(of: self.init()) }
}