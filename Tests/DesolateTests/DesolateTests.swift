import XCTest
@testable import Desolate

final class DesolateTests: XCTestCase {
    enum ProbeAction {
        case bidirectional(content: String, ref: Receiver<String>)
        case unidirectional(content: String)
    }

    actor Probe: AbstractDesolate, BaseActor, NonStop {
        func onMessage(msg: ProbeAction) async -> Signal  {
            switch msg {
            case .bidirectional(let content, let ref):
                ref.tell(with: content)
            case .unidirectional(_):
                break
            }
            return same
        }
    }

    func testProperties() async throws {
        let probe = Probe()

        try await unit("AbstractDesolate should have a proper Signal status") { e in
            let status = await probe.status
            status == .running ? e.fulfill() : ()
        }

        try await unit("Receive should finished within timeout") { e async in
            Task {
                await probe.receive(.unidirectional(content: "Message"))
                e.fulfill()
            }
        }
    }

    func testTell() throws {
        try unit("Desolate should be able to receive responses from a synchronous input", timeout: 1.0) { e in
            let desolate = Probe.make()
            desolate.tell(with: .unidirectional(content: "Hello"))
            e.fulfill()
        }
    }

    func testAsk() async throws {
        try await unit("Desolate when conforming to Delivery should be able to receive responses", timeout: 5.0) { e in
            let desolate = Probe.make()

            let response = await desolate.ask { .bidirectional(content: "Hello", ref: $0) }

            if response == "Hello" {
                e.fulfill()
            }
        }
    }

    func testFD() throws {
        let desolate = FD.of(String.self, initial: 0) { act, msg in
            switch msg {
            case "increment":
                return await .running(state: act.current + 1)
            case "decrement":
                return await .running(state: act.current - 1)
            case "schedule":
                let some = Task.init { await Task.sleep(10.milliseconds) }
                await act.pipeToSelf(some) { _ in "increment" }
                return .same
            default:
                return .same
            }
        }

        desolate.tell(with: "increment")
    }
}
