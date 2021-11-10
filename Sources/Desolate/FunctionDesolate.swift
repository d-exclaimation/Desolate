//
//  FunctionDesolate.swift
//  Desolate
//
//  Created by d-exclaimation on 6:15 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// Functional Desolate
public enum FunctionDesolate<MessageType, State> {
    /// Functional wrapper around State and Signal
    public enum FunctionalSignal {
        case stopped, same
        case running(state: State)
        case end(with: State)
        case ignoring(state: State, count: Int = 1)
    }

    /// Functional wrapper around State and Signal
    public typealias FS = FunctionalSignal

    /// Function for message receiver
    public typealias OnMessage = (Base, MessageType) async -> FunctionalSignal

    /// Base actor functional desolate
    public actor Base: AbstractDesolate {
        public var status: Signal = .running

        private var messageReceiver: OnMessage
        private var state: State

        public func onMessage(msg: MessageType) async -> Signal {
            switch await messageReceiver(self, msg) {
            case .same:
                return .running
            case .running(state: let newState):
                state = newState
                return .running
            case .stopped:
                return .stopped
            case .ignoring(state: let newState, count: let count):
                state = newState
                return .ignoring(count: count)
            case .end(with: let with):
                state = with
                return .stopped
            }
        }

        /// Getter current state for this actor
        public var current: State { state }

        init(initialState: State, _ fn: @escaping OnMessage) {
            messageReceiver = fn
            state = initialState
        }
    }

    /// Create a new Desolate actor functionality
    public static func of(_ type: MessageType.Type = MessageType.self, initial: State, fn: @escaping OnMessage) -> Desolate<Base> {
        Desolate(of: Base(initialState: initial, fn))
    }
}

/// Functional Desolate
public typealias FD<MessageType, State> = FunctionDesolate<MessageType, State>