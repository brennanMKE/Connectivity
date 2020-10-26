import Foundation
import AudioToolbox
import ConnectivityKit

typealias AppStateChangedHandler = (AppState) -> Void

class AppState {
    static let OnlineEmojis = ["🤩", "🥳", "😎"]
    static let OfflineEmojis = ["😭", "😤", "🤬"]

    var networkEmoji: String = ""
    var networkStatus: String = ""
    var pathStatus: String = ""
    var interfaces: String = ""

    var appStateChangedHandler: AppStateChangedHandler?

    private var monitor = ConnectivityMonitor()
    private let queue = DispatchQueue(label: "com.acme.connectivity", qos: .background)

    var onlineEmoji: String {
        Self.OnlineEmojis.randomElement() ?? ""
    }

    var offlineEmoji: String {
        Self.OfflineEmojis.randomElement() ?? ""
    }

    func startMonitor() {
        debugPrint("Starting monitor")
        monitor.start(pathUpdateQueue: queue, pathUpdateHandler: didUpdate(path:))
    }

    func stopMonitor() {
        debugPrint("Stopping monitor")
        monitor.cancel()
    }

    func didUpdate(path: ConnectivityPath) {
        debugPrint("Path: \(path)")

        if path.isExpensive {
            debugPrint("Network path is considered expensive.")
        }

        let offline = path.status == .unsatisfied
        dispatchPrecondition(condition: .notOnQueue(.main))
        let previousNetworkStatus = networkStatus
        networkEmoji = offline ? offlineEmoji : onlineEmoji
        networkStatus = offline ? "offline" : "online \(path.isExpensive ? "💸" : "💰")"
        pathStatus = String(describing: path.status)
        interfaces = path.availableInterfaces
            .map { "\($0.name) (\($0.type))" }
            .joined(separator: ", ")
        DispatchQueue.main.sync {
            appStateChangedHandler?(self)
        }
        if previousNetworkStatus != "" && networkStatus != previousNetworkStatus {
            vibrate()
        }
    }

    func vibrate() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}
