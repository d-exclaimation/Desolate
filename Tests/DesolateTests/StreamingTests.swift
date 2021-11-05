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
}