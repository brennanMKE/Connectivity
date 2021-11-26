import Foundation
import AudioToolbox
import Reachability
import ConnectivityKit

class AppEnvironment: ObservableObject {
    static let OnlineEmojis = ["🤩", "🥳", "😎"]
    static let OfflineEmojis = ["😭", "😤", "🤬"]

    @Published var networkEmoji: String = ""
    @Published var networkStatus: String = ""
    @Published var pathStatus: String = ""
    @Published var interfaces: String = ""

    private var monitor = ConnectivityMonitor()

    var onlineEmoji: String {
        Self.OnlineEmojis.randomElement() ?? ""
    }

    var offlineEmoji: String {
        Self.OfflineEmojis.randomElement() ?? ""
    }

    func startMonitor() {
        debugPrint("Starting monitor")
        monitor.start(pathUpdateQueue: .main, pathUpdateHandler: didUpdate(path:))
    }

    func stopMonitor() {
        debugPrint("Stopping monitor")
        monitor.cancel()
    }

    func didUpdate(path: ConnectivityPath) {
        dispatchPrecondition(condition: .onQueue(.main))

        debugPrint("Path: \(path)")

        if path.isExpensive {
            debugPrint("Network path is considered expensive.")
        }

        let previousNetworkStatus = networkStatus

        let offline = path.status == .unsatisfied
        networkEmoji = offline ? offlineEmoji : onlineEmoji
        networkStatus = offline ? "offline" : "online \(path.isExpensive ? "💸" : "💰")"
        pathStatus = String(describing: path.status)
        interfaces = path.availableInterfaces
            .map { "\($0.name) (\($0.type))" }
            .joined(separator: ", ")

        if previousNetworkStatus != "" && networkStatus != previousNetworkStatus {
            vibrate()
        }
    }

    func vibrate() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}
