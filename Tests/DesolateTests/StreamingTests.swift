//
//  StreamingTests.swift.swift
//  Desolate
//
//  Created by d-exclaimation on 10:35 AM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation
import XCTest
@testable import Desolate

final class StreamingTests: XCTestCase {
    func testNozzle() async throws {
        try await unit("Nozzle should be a cold stream") { e async in
            let expected = [1, 2, 3]
            var result = [Int]()
            let nozzle = Nozzle<Int> { pipe async in
                for i in expected {
                    await pipe.emit(i)
                }
                await pipe.close()
            }

            for await each in nozzle {
                result.append(each)
            }

            for i in result.indices {
                if expected[i] != result[i] {
                    return
                }
            }
            e.fulfill()
        }
    }

    func testSource() async {
        let (stream, desolate) = Source<Int>.desolate()
        let job1: UDeferred<Int> = Task {
            var res = [String]()
            for await each in stream.map({ "Task.init -> \($0)" }) {
                res.append(each)
            }
            return res.count
        }
        let job2: UDeferred<Int>  = Task {
            var res = [String]()
            for await each in stream.map({ "Task.detached -> \($0)" }) {
                res.append(each)
            }
            return res.count
        }

        Task.detached {
            try await Task.sleep(nanoseconds: 1.seconds)
            for i in 1...10 {
                await desolate.task(with: .next(i))
            }
            await desolate.task(with: .complete)
        }
        let c1 = await job1.value
        let c2 = await job2.value
        XCTAssertEqual(c1, c2)
    }

    actor Procrastinator: AbstractDesolate, NonStop, BaseActor {
        func onMessage(msg: (Int, Receiver<Int>)) async -> Signal {
            let (num, ref) = msg
            Task.detached {
                try await Task.sleep(nanoseconds: 1.seconds)
                await ref.task(with: num)
            }
            return same
        }
    }

    func testSourceUsingReceiver() async {
        let desolate = Procrastinator.create()
        let (stream, streamDesolate) = Source<String>.desolate()

        let task = Task.detached {
            var last = 0
            for await each in stream.nozzle() {
                guard last < 2 else {
                    await streamDesolate.task(with: .complete)
                    return
                }
                print(each)
                last += 1
            }
        }
        await desolate.task(with: (1,  streamDesolate.ref { .next("\($0)") }))
        await desolate.task(with: (2,  streamDesolate.ref { .next("\($0)") }))
        await desolate.task(with: (3,  streamDesolate.ref { .next("\($0)") }))
        let _ = await task.result
    }

    func testReservoirWithNozzle() async throws {
        let reservoir = Reservoir<String, Int>()
        let e1 = XCTestExpectation(description: "Topic 1 receive 3 messages")
        let e2 = XCTestExpectation(description: "Topic 1 receive 3 messages")
        let nozzle1 = await reservoir.nozzle(for: "topic:1")
        let nozzle2 = await reservoir.nozzle(for: "topic:1")
        let nozzle3 = await reservoir.nozzle(for: "topic:2")

        Task.detached {
            var count = [Int]()
            for await each in nozzle1 {
                count.append(each)
            }
            if count.count == 3 {
                e1.fulfill()
            } else {
                print("topic:1 -> \(count)")
            }
        }

        Task.detached {
            var count = [Int]()
            for await each in nozzle2 {
                count.append(each)
            }
            if count.count == 3 {
                e2.fulfill()
            } else {
                print("topic:1 -> \(count)")
            }
        }

        Task.detached {
            var count = [Int]()
            for await each in nozzle3 {
                count.append(each)
            }
            if count.count == 2 {
                e2.fulfill()
            } else {
                print("topic:2 -> \(count)")
            }
        }

        try await Task.sleep(nanoseconds: 100.milliseconds)

        await reservoir.dispatch(for: "topic:1", 1)
        await reservoir.dispatch(for: "topic:2", 2)
        await reservoir.dispatch(for: "topic:2", 2)
        await reservoir.dispatch(for: "topic:1", 3)
        await reservoir.dispatch(for: "topic:1", 5)
        reservoir.close(for: "topic:1")
        reservoir.close(for: "topic:2")
        wait(for: [e1, e2], timeout: 2)
    }

    func testReservoirWithSources() async throws {
        let reservoir = Reservoir<String, Int>()
        let e1 = XCTestExpectation(description: "Topic 1 receive 3 messages")
        let e2 = XCTestExpectation(description: "Topic 2 receive 1 messages")
        let source1 = await reservoir.source(for: "topic:1")
        let source2 = await reservoir.source(for: "topic:2")

        Task.detached {
            var count = [Int]()
            for await each in source1.nozzle() {
                count.append(each)
            }
            if count.count == 3 {
                e1.fulfill()
            } else {
                print("topic:1 -> \(count)")
            }
        }

        Task.detached {
            var count = [Int]()
            for await each in source2.nozzle() {
                count.append(each)
            }
            if count.count == 1 {
                e2.fulfill()
            } else {
                print("topic:2 -> \(count)")
            }
        }

        try await Task.sleep(nanoseconds: 100.milliseconds)

        await reservoir.dispatch(for: "topic:1", 1)
        await reservoir.dispatch(for: "topic:2", 2)
        await reservoir.dispatch(for: "topic:1", 3)
        await reservoir.dispatch(for: "topic:1", 5)
        reservoir.close(for: "topic:1")
        reservoir.close(for: "topic:2")
        wait(for: [e1, e2], timeout: 2)
    }

    func testBenchmark() async throws {
        let repeated = 10
        let task0 = Task.init { () -> (TimeInterval, Int) in
            await withTaskGroup(of: (TimeInterval, Int).self, returning: (TimeInterval, Int).self) { group in
                for i in 1...repeated {
                    group.addTask {
                        let (nozzle, desolate) = Nozzle<Int>.desolate()
                        Task.init {
                            for i in 0...(i * i * i) {
                                await desolate.task(with: i)
                                await Task.requeue()
                            }
                            await desolate.task(with: nil)
                        }
                        let start = Date()
                        var all = 0
                        for await _ in nozzle {
                            all += 1
                        }
                        return (abs(start.timeIntervalSinceNow * 1000), all)
                    }
                }

                var speeds = [TimeInterval]()
                var accuracies = [Int]()
                for await res in group {
                    let (speed, accuracy) = res
                    speeds.append(speed)
                    accuracies.append(100 - abs(101 - accuracy) / 101 * 100)
                }

                return (speeds.reduce(0.0) { acc, x in acc + x } / Double(speeds.count), accuracies.reduce(0) { acc, x in acc + x } / accuracies.count)
            }

        }

        let task1 = Task.init { () -> (TimeInterval, Int) in
            await withTaskGroup(of: (TimeInterval, Int).self, returning: (TimeInterval, Int).self) { group in
                for i in 1...repeated {
                    group.addTask {
                        let asyncStream = AsyncStream.init(Int.self) { continuation in
                            Task.init {
                                for i in 0...(i * i * i) {
                                    continuation.yield(i)
                                    await Task.requeue()
                                }
                                continuation.finish()
                            }
                        }

                        let start = Date()
                        var all = 0
                        for await _ in asyncStream {
                            all += 1
                        }
                        return (abs(start.timeIntervalSinceNow * 1000), all)
                    }
                }

                var speeds = [TimeInterval]()
                var accuracies = [Int]()
                for await res in group {
                    let (speed, accuracy) = res
                    speeds.append(speed)
                    accuracies.append(100 - abs(101 - accuracy) / 101 * 100)
                }

                return (speeds.reduce(0.0) { acc, x in acc + x } / Double(speeds.count), accuracies.reduce(0) { acc, x in acc + x } / accuracies.count)
            }
        }

        let (nozzle, acc0) = await task0.value
        let (stream, acc1) = await task1.value
        print("Nozzle is about \((nozzle / stream * 100).rounded())% the speed of stream with accuracy of \(100 - abs(101 - acc0) / 101 * 100)%")
        print("Stream is about \((stream / nozzle * 100).rounded())% the speed of nozzle with accuracy of \(100 - abs(101 - acc1) / 101 * 100)%")
    }

    func testOnTermination() async throws {
        let (nozzle, engine) = Nozzle<Int>.desolate()
        let expect = XCTestExpectation(description: "On termination should be called")
        nozzle.onTermination {
            expect.fulfill()
            print("Done")
        }

        Task.init {
            for await each in nozzle {
                print("\(each)")
            }
        }

        Task.init {
            try await Task.sleep(nanoseconds: 1000 * 1000 * 200)
            nozzle.shutdown()
        }

        Task.init {
            for i in 0...1000 {
                await engine.task(with: i)
                try await Task.sleep(nanoseconds: 1000 * 1000 * 10)
            }
        }

        wait(for: [expect], timeout: 1)
    }
}
