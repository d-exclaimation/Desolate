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
        let atomic = hook { 1 }

        @Desolated var safe = 1
    }

    func testHook() {
        let cls = MyClass()
        cls.atomic.set { $0 + 1 }

        XCTAssert(cls.atomic.get() == 2)
    }

    func testDecorator() {
        let cls = MyClass()
        let prev = cls.safe
        cls.safe = prev + 1
        XCTAssert(cls.safe == 2)
    }

    func testTimer() throws {
        try unit("Set timer") { e in
            setTimeout(delay: 10.milliseconds) {
                e.fulfill()
            }
        }
    }
}
