import HotwireNative
import UIKit

final class CallInitiateComponent: BridgeComponent {
    override class var name: String { "call-initiate" }

    private struct CallPayload: Decodable {
        let phone: String
    }

    override func onReceive(message: Message) {
        guard message.event == "call",
              let payload: CallPayload = message.data(),
              let url = Self.telURL(for: payload.phone),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    nonisolated static func telURL(for phoneNumber: String) -> URL? {
        let digits = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard !digits.isEmpty else { return nil }
        return URL(string: "tel://\(digits)")
    }
}
