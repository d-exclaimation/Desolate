# Desolate

*Prototype* actor and async/await toolkit for Swift 5.5+

```swift
import Desolate

enum StoreEvent: CustomStringConvertible {
    case update(key: String, item: String)
    case store(item: String, ref: RecipientRef<String>)
    case add(item: String)
    case get(key: String, ref: RecipientRef<String?>)
    case getAll(ref: RecipientRef<[String]>)
    case delete(key: String)

    var description: String {
        switch self {
        case .update(key: let key, item: let item):
            return "PUT/PATCH: \(key) -> \"\(item)\""
        case .store(item: let item, ref: _):
            return "POST: \"\(item)\""
        case .add(item: let item):
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

actor Store: AbstractDesolate {
    public var status: Signal = .running

    private var storage: [String: (String, Date)] = [:]

    public func onMessage(msg: StoreEvent) async -> Signal {
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
}

let desolate = Desolate(of: Store())

desolate.tell(with: .add(item: "Hello")) // Passing message to Actor while maintaining actor-isolation
```

### Feedback

If you have any feedback, feel free to reach out through the issues tab or through my
Twitter [@d_exclaimation](https://twitter.com/d_exclaimation).