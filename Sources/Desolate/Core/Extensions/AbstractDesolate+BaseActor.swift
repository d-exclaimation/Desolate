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
    /// a complete desolate can be initialized using the static `create()` method.
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
    /// let desolate: Desolate<Logger> = Logger.create()
    ///
    /// desolate.tell(with: "Hello")
    /// ```
    ///
    /// - Returns: A complete Desolate
    public static func create() -> Desolate<Self> { Desolate(of: self.init()) }

    /// Given a AbstractDesolate conforms to a BaseActor,
    /// a complete desolate can be initialized using the static `make()` method.
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
    /// let desolate: Desolate<Logger> = Logger.make()
    ///
    /// desolate.tell(with: "Hello")
    /// ```
    ///
    /// - Returns: A complete Desolate
    public static func make() -> Desolate<Self> { Desolate(of: self.init()) }

    /// Create the desolate with the actor itself
    public static func construct() -> (Self, Desolate<Self>) {
        let actor = self.init()
        return (actor, Desolate(of: actor))
    }

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
    @available(*, deprecated, message: "Use `create` / `make` instead")
    public static func new() -> Desolate<Self> { Desolate(of: self.init()) }


}