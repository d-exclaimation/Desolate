# Getting started with a simple example

Desolate example usage

## Overview

Let say, you want to store multiple strings that doesn't create data races. Something like this:

```swift
enum Actions {
    // Receiver used to return a value of certain type
    case get(id: UUID, ref: Receiver<String?>) 

    // Another usage of Receiver
    case getAll(ref: Receiver<[(UUID, String)]>)

    case set(content: String)
}

// Core protocol for the Desolate.
//              |   Utility protocol to automatic definiton of Desolate status.
//              |                 |  Utility protocol to automatic create a static initializer.
//              |                 |         |
//              v                 v         v
actor Storage: AbstractDesolate, NonStop, BaseActor {
    
    private var state: [UUID: String] = [:] // Isolated state properties
    
    // Required method for the AbstractDesolate
    func onMessage(msg: Actions) async -> Signal {
        switch msg {
        case .get(let id, let ref):
            // Send the result to the Receiver, and await until result was delivered
            await ref.task(with: state[id]) 
        case .getAll(let ref):
            // Same goes here, but this approach does not wait delivery
            ref.tell(with: state.enumerated().map { $0 })
        case .set(let content):
            // Concurrent safe mutation since this is isolated
            let id = UUID()
            state[id] = content
        }

        return same // Return the same status signal (from NonStop)
    }
}
```

So how would you interact with this actor from like the main thread?

```swift
@main
struct Main {
    static func main() {
        // Using Swift Actor as it is
        let storage = Storage()

        // error: async call in a function that does not support concurrency 
        storage.onMessage(msg: .set(content: "Hello")) 

        ???
    }
}
```

You can use the ``Desolate/Desolate/init(of:)`` for most actors but this example we have ``Desolate/BaseActor`` which gives a static initializer, 
named ``Desolate/AbstractDesolate/create()``.

```swift
@main
struct Main {
    static func main() {
        // Using Desolate as an interface
        let storage = Storage.create()

        // no error, does not block next line
        storage.tell(with: .set(content: "Hello")) 

        // Asking for return type will give back Task<ReturnType, Error>
        // (as that's the new Swift unit for concurrency)
        let task: Task<[(UUID, String)], Error> = storage.request { .getAll(ref: $0) }

        Task.detached {
            await Main.asyncFunction() 
        }
        ...
    }

    static func asyncFunction() async throws {
        let storage = Storage.create()

        // Same here, does not block next line
        storage.tell(with: .set(content: "Hello")) 

        // Using in async block
        // .task(with:) is similar to .tell(with:) but is async so it can awaited
        await storage.task(with: .set(content: "Hello from async"))

        // Asking for return type will give back awaitable result
        // .ask throws an error if the actor never returned anything or the inbox being used failed
        let contents: [(UUID, String)] = try await storage.ask { .getAll(ref: $0) }

        // .query return a Result instead throwing an error
        let result: Result<[(UUID, String)], Error> = await storage.query { .getAll(ref: $0) }
    }
}
```