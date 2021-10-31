//
//  Counter.swift
//  Desolate
//
//  Created by d-exclaimation on 2:13 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

public actor Counter {
    var state = 0

    func increment() async  {
        state += 1
    }

    func decrement() async {
        state -= 1
    }

    func current() async -> Int {
        state
    }

    func reset() async {
        state = 0
    }
}
