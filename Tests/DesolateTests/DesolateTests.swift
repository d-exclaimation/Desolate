import XCTest
@testable import Desolate

final class DesolateTests: XCTestCase {
    enum ProbeAction {
        case bidirectional(content: String, ref: Receiver<String>)
        case unidirectional(content: String)
    }

    actor Probe: AbstractDesolate {
        var status: Signal = .running

        func onMessage(msg: ProbeAction) async -> Signal {
            switch msg {
            case .bidirectional(let content, let ref):
                ref.tell(with: content)
            case .unidirectional(_):
                break
            }
            return .running
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
            let desolate = Desolate(of: Probe())
            desolate.tell(with: .unidirectional(content: "Hello"))
            e.fulfill()
        }
    }

    func testAsk() async throws {
        try await unit("Desolate when conforming to Delivery should be able to receive responses", timeout: 5.0) { e in
            let desolate = Desolate(of: Probe())

            let response = try await desolate.ask { .bidirectional(content: "Hello", ref: $0) }

            if response == "Hello" {
                e.fulfill()
            }
        }
    }
}
