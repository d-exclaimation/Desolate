//
//  Store.swift
//  Conduits
//
//  Created by d-exclaimation on 6:57 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

public enum StoreEvent: CustomStringConvertible {
    case update(key: String, item: String)
    case store(item: String, ref: RecipientRef<String>)
    case get(key: String, ref: RecipientRef<String?>)
    case getAll(ref: RecipientRef<[String]>)
    case delete(key: String)

    public var description: String {
        switch self {
        case .update(key: let key, item: let item):
            return "PUT/PATCH: \(key) -> \"\(item)\""
        case .store(item: let item, ref: _):
            return "POST: \"\(item)\""
        case .get(key: let key, ref: _):
            return "GET: \(key)"
        case .getAll(ref: _):
            return "GET: *"
        case .delete(key: let key):
            return "DELETE: \(key)"
        }
    }
}

public actor Store: AbstractBehavior {
    public var status: BehaviorSignal = .running

    private var storage: [String: (String, Date)] = [:]

    public func onMessage(msg: StoreEvent) async -> BehaviorSignal {
        print("Received: \(msg)")

        switch msg {
        case .update(let key, let item):
            storage[key] = (item, Date())

        case .store(let item, let ref):
            let key = UUID().uuidString
            storage[key] = (item, Date())
            ref.tell(with: key)

        case .get(let key, let ref):
            ref.tell(with: storage[key]?.0)

        case .getAll(let ref):
            ref.tell(with: storage.values.sorted { $0.1 <= $1.1 } .map{ $0.0 })

        case .delete(let key):
            storage.removeValue(forKey: key)
        }

        return .running
    }

    public static func behavior() -> ActorRef<Store> { ActorRef(of: Store()) }
}