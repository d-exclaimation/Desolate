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
    func testSource() async {
        let (source, desolate) = Slipstream<Int>.desolate()
        let job = Task {
            for await each in source.map({ "Task.init -> \($0)" }) {
                print(each)
            }
        }
        Task.detached {
            for await each in source.map({ "Task.detached -> \($0)" }) {
                print(each)
            }
        }

        Task.detached {
            await Task.sleep(1.seconds)
            for i in 1...10 {
                await desolate.task(with: .give(i))
            }
            await desolate.task(with: .complete)
        }
        let _ = await job.result
    }
}