import HotwireNative
import UIKit

final class CallInitiateComponent: BridgeComponent {
    override class var name: String { "call-initiate" }

    override func onReceive(message: Message) {
        guard message.event == "dial",
              let phoneNumber = message.data["phone"] as? String else { return }
        dial(phoneNumber)
    }

    // MARK: - Private

    private func dial(_ phoneNumber: String) {
        let digits = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard let url = URL(string: "tel://\(digits)"),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}
