import Foundation

func timed(fn: @escaping () -> Void) {
    let start = Date()
    fn()
    let endedAt = abs(start.timeIntervalSinceNow * 1000)
    print("[timed]: Finished at \(endedAt) ms")
}

let actorRef = Store.behavior()

timed {
    let task = actorRef.request {
        .getAll(ref: $0)
    }

    switch task.wait() {
    case .success(let res):
        print(res)
    case .failure(let error):
        print(error.localizedDescription)
    }
}

timed {
    bridge {
        let key0 = try await actorRef.ask { .store(item: "Hello", ref: $0) }
        print(key0)
        let key1 = try await actorRef.ask { .store(item: "PP", ref: $0) }
        print(key1)

        let res = try await actorRef.ask { .getAll(ref: $0) }

        print(res.joined(separator: ", "))
    }
}

