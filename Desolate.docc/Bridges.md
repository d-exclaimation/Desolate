# Connecting the synchronous to the asynchronous world using Bridges

A tour of brigdes to connect asynchronous code to synchronous code

With most languages implementation on `async/await`, asynchronous code aren't allowed to called in synchronous code even when not expecting any value.

Some implementation offer the option to make the `main` function to be async or having a blocking executor. Swift's implementation of concurrency makes that every asynchronous operation to be a [`Task`](https://developer.apple.com/documentation/swift/task/). Using unstructured concurrency, you can declare and run [`Task`](https://developer.apple.com/documentation/swift/task/) on the main thread, and let it be handled by the scheduler. Using [`Task`](https://developer.apple.com/documentation/swift/task/) will look similar to using other implementation's blocking executor.

Rust's implementation (`async/await`)
```rust
use futures::executor::block_on;

async fn hello_world() {
    println!("hello, world!");
}

fn main() {
    let future = hello_world(); 
    block_on(future);
}
```

Scala's implementation (`Future`)
```scala
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.Await
import scala.async.Async.{async, await}

def helloWorld(): Future[Unit] = async {
     println("hello, world!")
}

@main def main(): Unit {
    Await.ready(helloWorld())
}
```

The problem comes with that [`Task`](https://developer.apple.com/documentation/swift/task/) initilizer does not work the same way. [`Task`](https://developer.apple.com/documentation/swift/task/) are ran seperate but does not block anything by default. The main thread will continue and when it finishes all Tasks are dropped (similar scenario with Go's goroutine). To wait for a Task to finish, you need to await it in another asynchronous scope.

```swift
func helloWorld() async {
    print("hello, world!")
}

@main
struct Main {
    static func main() {
        Task.init {
            await Task.sleep(1000 * 1000 * 1000 /* 1 second in nanosecond */)
            await helloWorld()
        }
    }
}
```

The code above will not print anything, as the main thread will finish before the Task print any value, in which it will exit the program.

``Desolate`` comes with bridges to to be the equivalent to the blocking executors. There are a couple ones, but the simplest one is ``Desolate/bridge(for:)``, which will just execute an async function on a seperate Task and blocks until completion.

```swift
import Desolate 

func helloWorld() async {
    print("hello, world!")
}

@main
struct Main {
    static func main() {
        bridge {
            await Task.sleep(1000 * 1000 * 1000 /* 1 second in nanosecond */)
            await helloWorld()
        }
        // Will not be called until Task above finishes
        print("Hello??")
    }
}
```

On top of that, ``Desolate`` provide extentions to [`Task`](https://developer.apple.com/documentation/swift/task/) mostly to get feature parody with something like `Futures` / `Promises` (and Swift-NIO `EventLoopFuture`) and also aliases to describe 2 kind of common Task, ``Desolate/Deferred`` (Task with returned value) and ``Desolate/Job`` (Task with no return value)

```swift
func random() async -> Int {
    Int.random(in: 1...10)
}

let task0: Deferred<Int> = Task { await random() } // Deferred<T> -> Task<T, Error>

let task1: Deferred<String> = task0
  .map { $0 + 10 }
  .flatMap { $0 - await random() }
  .map { $0 * 2 }
  .map { "Result -> \($0)" }

bridge {
    let str = try await task1.value
    print(str)
}
```
