//
//  AbstractDesolateTests.swift
//  Desolate
//
//  Created by d-exclaimation on 7:05 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation
import XCTest
@testable import Desolate

final class AbstractDesolateTests: XCTestCase {
    actor Logger: AbstractDesolate {
        var status: Signal = .running

        var curr: Int = 0

        func onMessage(msg: Int) async -> Signal {
            if curr <= msg {
                curr = msg
            }
            return .running
        }
    }

    func testTellOrdered() throws {
        try unit("AbstractDesolate should maintain the order of message when using tell") { e in
            let desolate = Desolate(of: Logger.init())
            for i in 0...3 {
                desolate.tell(with: i)
            }
            e.fulfill()
        }

    }

    func testTaskUntilFinishes() async throws {
        try await unit("AbstractDesolate should be able to wait for finished execution using Task") { e async in
            let desolate = Desolate(of: Logger.init())
            await desolate.task(with: 2)
            e.fulfill()
        }
    }

    func testConduit() throws {
        func asyncCode() async -> Int { 1 }
        try unit("Conduit should not create data race and allow bridging the async value to the sync block") { e in
            let res = conduit(timeout: 1.0) {
                await asyncCode()
            }

            switch res {
            case .success(let int):
                XCTAssert(int == 1)
                e.fulfill()
            case .failure(_):
                XCTAssert(false)
            }
        }
    }
}
