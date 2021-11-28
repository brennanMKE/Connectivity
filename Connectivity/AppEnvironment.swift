import Foundation
import AudioToolbox
import Reachability
import ConnectivityKit
import Combine

enum ConnectivityBehavior {
    case closure
    case combine
}

class AppEnvironment: ObservableObject {
    static let OnlineEmojis = ["🤩", "🥳", "😎"]
    static let OfflineEmojis = ["😭", "😤", "🤬"]

    @Published var networkEmoji: String = ""
    @Published var pathStatus: String = ""
    @Published var interfaces: String = ""
    @Published var networkStatus: String = "" {
        didSet {
            if oldValue != "" && oldValue != networkStatus {
                vibrate()
            }
        }
    }

    let behavior: ConnectivityBehavior = .combine
    private var monitor: ConnectivityMonitor?
    private var observer: ConnectivityObserver?
    private var cancellable: AnyCancellable?

    var onlineEmoji: String {
        Self.OnlineEmojis.randomElement() ?? ""
    }

    var offlineEmoji: String {
        Self.OfflineEmojis.randomElement() ?? ""
    }

    func startMonitor() {
        switch behavior {
        case .closure:
            let monitor = ConnectivityMonitor()
            monitor.start(pathUpdateQueue: .main, pathUpdateHandler: handlePathUpdate(path:))
            self.monitor = monitor
        case .combine:
            let observer = ConnectivityObserver()
            let publisher = observer.start(pathUpdateQueue: .main)
            let cancellable = publisher.sink(receiveCompletion: { _ in
                print("Observer completed")
            }, receiveValue: handlePathUpdate(path:))
            self.observer = observer
            self.cancellable = cancellable
        }
    }

    func stopMonitor() {
        switch behavior {
        case .closure:
            monitor?.cancel()
            monitor = nil
        case .combine:
            observer?.cancel()
            cancellable?.cancel()
            observer = nil
            cancellable = nil
        }
    }

    func handlePathUpdate(path: ConnectivityPath) {
        dispatchPrecondition(condition: .onQueue(.main))

        if path.isExpensive {
            debugPrint("Network path is considered expensive.")
        }

        let offline = path.status == .unsatisfied
        networkEmoji = offline ? offlineEmoji : onlineEmoji
        networkStatus = offline ? "offline" : "online \(path.isExpensive ? "💸" : "💰")"
        pathStatus = String(describing: path.status)
        interfaces = path.availableInterfaces
            .map { "\($0.name) (\($0.type))" }
            .joined(separator: ", ")
    }

    func vibrate() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}
