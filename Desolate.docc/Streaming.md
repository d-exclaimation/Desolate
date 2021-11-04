# Elevating concurrency using streaming based data structures

A tour showing how Desolate and Swift Actors being used with Swift's new AsyncSequence protocol


With Swift 5.5, there is also a new concurrency feature in the form of a protocol called [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence). Anything that conforms to [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence) can be used in a `for await` loop.

They look familar from `Javascript`'s `asyncIterator`. 

```swift
struct AsyncArray: AsyncSequence {
    ...
}

let arr: AsyncArray

for await element in arr {
    // do something
}
```

This protocol defines the base for building streaming data structure. Collection data structured that each element are time bounded.

``Desolate`` comes with one built-in, ``Desolate/Nozzle``, which is a general purpose cold observable stream (cold as in it creates a data producer for each subscriber, when subscribe not before). It also come with multiple ways of initializing and more coming.

```swift
let collectionNuzz: Nuzzle<Int> = Nuzzle.of(1, 2, 3, 4, 5, 6, 7) 

Task.detached {
    // Start consuming
    for await each in collectionNuzz {
        print(each)
    }    
}

// Do something else in the mean time
```

``Desolate/Nozzle`` is built with Swift Actors and leverage Desolate capabilities to create a robust and efficient stream. You can see that by using ``Desolate/Nozzle/desolate()`` initializer.

```swift
let (nuzz, desolate) = Nuzzle<Int>.desolate()

Task.init {
    // Start consuming
    for await each in nuzz {
        print("Received \(each)")
    }    
}

desolate.tell(with: 10)
// Received 10
desolate.tell(with: 69)
// Received 69
```

``Desolate/Nozzle`` are cold which may not be suitable for situation where incoming data are dynamic and there are multiple maybe dynamic amount of consumer / subscriber. This is where ``Desolate/Jet`` comes in basically a hot obserable implementation.

```swift
let (jet, upstream) = Jet<Int>.desolate()

Task.init {
    await withTaskGroup(of: Void.self) { group in 
        // Dynamic multiple consumer, ran parallel using TaskGroup
        for i in 0..<3 {
            group.addTask {
                // Compute a new Nuzzle for each consumer
                for await each in jet.nuzzle() {
                    print("\(i): Received \(each)")
                }    
            }
        }
    }
}
upstream.tell(with: .next(10))
// 0: Received 10
// 2: Received 10
// 1: Received 10
```
