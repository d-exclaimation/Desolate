//
//  Task+Conduit.swift
//  Desolate
//
//  Created by d-exclaimation on 4:45 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Task {
    /// Blocking-ly await a Task in the top level thread
    ///
    /// - Parameters:
    ///   - priority: TaskPriority used for the Task
    ///   - timeout: Timeout for waiting the result
    /// - Returns: A Result for Task's Success and BridgeError
    func wait(priority: TaskPriority? = nil, timeout: DispatchTime = DispatchTime.now() + DispatchTimeInterval.seconds(5)) -> Result<Success, CollapsedBridge> {
        var result: Result<Success, CollapsedBridge> = .failure(.idle)

        func closure() async throws {
            do {
                let res = try await value
                result = .success(res)
            } catch {
                result = .failure(.failure(error: error))
            }
        }

        switch bridge(priority: priority, timeout: timeout, throw: closure) {
        case .success(_):
            return result
        case .failure(let err):
            return .failure(err)
        }
    }
}