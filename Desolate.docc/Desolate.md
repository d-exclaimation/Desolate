# ``Desolate``

A scalable concurrency toolkit for Swift 5.5+

![Desolate](Birds.png)


Desolate is a toolkit for Swift 5.5+ Actors and Concurrency capabilities. The library provide structures to model Swift Actors using ``Desolate/Desolate`` that maintains its isolation while allowing both synchronous and asynchronous code to interface with the actors. ``Desolate/Desolate`` can created with any Actor that conforms to the ``Desolate/AbstractDesolate`` which only require an ``Desolate/AbstractDesolate/onMessage(msg:)`` method. 

The library also comes with a lot utilities for common use cases when dealing with `async/await` and Swift Actors with similar API and strategies to [`akka`](https://akka.io/) toolkit from the [`Scala`](https://scala-lang.org/) `/` [`Java`](https://www.java.com/) world. Common utilities like bridging between asynchronous to synchronous code,  etc.

More in depth, look into:
- <doc:Example>, for example usage / tutorial
- <doc:Diagram>, for explaination how ``Desolate`` work