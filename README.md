# Desolate

A scalable concurrency toolkit for Swift 5.5+

[`Desolate`](https://github.com/d-exclaimation/desolate) is a toolkit for Swift 5.5+ Actors and Concurrency capabilities. The library provide structures to model Swift Actors using [`Desolate`](https://github.com/d-exclaimation/desolate) that maintains its isolation while allowing both synchronous and asynchronous code to interface with the actors. [`Desolate`](https://github.com/d-exclaimation/desolate) can created with any Actor that conforms to the [`AbstractDesolate`](https://github.com/d-exclaimation/desolate/blob/main/Sources/Desolate/AbstractDesolate.swift) which only require an [`onMessage(msg:)`](https://github.com/d-exclaimation/desolate/blob/ded95df2beba461bc4d426ecc5d2b11162f16c13/Sources/Desolate/AbstractDesolate.swift#L23) method.

### Documentation

- [Documentation](https://swift-desolate.netlify.app/documentation/desolate)

### Usages/Examples

Simple concurrent safe store showing the maintained isolation even when actor is given messages from a main synchronous task
```swift
import Desolate

enum StoreEvent: CustomStringConvertible {
    case update(key: String, item: String)
    case store(item: String, ref: Receiver<String>)
    case add(item: String)
    case get(key: String, ref: Receiver<String?>)
    case getAll(ref: Receiver<[String]>)
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

actor Store: AbstractDesolate, NonStop {
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

        return same
    }
}

let desolate = Desolate(of: Store())

desolate.tell(with: .add(item: "Hello")) // Passing message to Actor while maintaining actor-isolation
```

### Feedback

If you have any feedback, feel free to reach out through the issues tab or through my
Twitter [@d_exclaimation](https://twitter.com/d_exclaimation).
