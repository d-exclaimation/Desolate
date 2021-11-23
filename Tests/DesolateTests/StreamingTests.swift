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
            let nozzle = Nozzle<Int>.init { emit, close async in
                for i in expected {
                    await emit(i)
                }
                await close()
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

    func testJet() async {
        let (stream, desolate) = Jet<Int>.desolate()
        let job = Task {
            for await each in stream.nozzle().map({ "Task.init -> \($0)" }) {
                print(each)
            }
        }
        Task.detached {
            for await each in stream.nozzle().map({ "Task.detached -> \($0)" }) {
                print(each)
            }
        }

        Task.detached {
            await Task.sleep(1.seconds)
            for i in 1...10 {
                await desolate.task(with: .next(i))
            }
            await desolate.task(with: .complete)
        }
        let _ = await job.result
    }

    actor Procrastinator: AbstractDesolate, NonStop, BaseActor {
        func onMessage(msg: (Int, Receiver<Int>)) async -> Signal {
            let (num, ref) = msg
            Task.detached {
                await Task.sleep(1.seconds)
                await ref.task(with: num)
            }
            return same
        }
    }

    func testJetUsingReceiver() async {
        let desolate = Procrastinator.create()
        let (stream, streamDesolate) = Jet<String>.desolate()

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
}