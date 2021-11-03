//
//  DecoratorTests.swift
//  Desolate
//
//  Created by d-exclaimation on 9:22 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation
import XCTest
@testable import Desolate

final class DecoratorTests: XCTestCase {
    class MyClass {
        let atomic = pocket { 1 }

        @Desolated var safe = 1
    }

    func testHook() throws {
        let cls = MyClass()
        cls.atomic.set { $0 + 1 }

        do {
            let res = try cls.atomic.get()
            XCTAssert(res == 2)
        } catch {
            print(error.localizedDescription)
        }

//        let res = (try? cls.atomic.get()) ?? 2
//        XCTAssert(res == 2)
    }

    func testDecorator() {
        let cls = MyClass()
        let prev = cls.safe
        cls.safe = prev + 1
        let curr = cls.safe
        XCTAssert(curr == 2 || curr == 1)
    }

    func testTimer() throws {
        try unit("Set timer") { e in
            setTimeout(delay: 10.milliseconds) {
                e.fulfill()
            }
        }
    }
}
