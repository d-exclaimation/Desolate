import XCTest
import class Foundation.Bundle
import Foundation
import Desolate

final class BridgeTest: XCTestCase {
    func testBridge() throws {
        func another() async -> Int {
            Thread.sleep(forTimeInterval: 1.1)
            return 0
        }
        let started = Date()
        bridge {
            let res = await another()
            assert(res == 0)
        }
        let ended = abs(started.timeIntervalSinceNow)
        assert(ended >= 1.0)
    }


    func testDispatch() throws {
        func another() async throws {
            Thread.sleep(forTimeInterval: 1.1)
            fatalError()
        }
        let started = Date()
        dispatch {
            try await another()
        }
        let ended = abs(started.timeIntervalSinceNow)
        assert(ended < 1.0)
    }
}

