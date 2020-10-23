import Foundation
import ConnectivityKit

class AppState: NSObject, ObservableObject {
    static let OnlineEmojis = ["🤩", "🥳", "😎"]
    static let OfflineEmojis = ["😭", "😤", "🤬"]

    @Published var networkEmoji: String = ""
    @Published var networkStatus: String = ""
    @Published var pathStatus: String = ""
    @Published var interfaces: String = ""

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
        monitor.start(queue: queue, pathUpdateHandler: didUpdate(path:))
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
        DispatchQueue.main.sync {
            networkEmoji = offline ? offlineEmoji : onlineEmoji
            networkStatus = offline ? "offline" : "online \(path.isExpensive ? "💸" : "💰")"
            pathStatus = String(describing: path.status)
            interfaces = path.availableInterfaces
                .map { "\($0.name) (\($0.type))" }
                .joined(separator: ", ")
        }
    }

    func preview() -> AppState {
        networkEmoji = onlineEmoji
        networkStatus = "online"
        pathStatus = "satisfied"
        interfaces = "en0"
        return self
    }
}
