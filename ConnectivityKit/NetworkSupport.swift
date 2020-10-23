import Foundation
import Network

@available(iOS 12.0, *)
extension ConnectivityStatus {
    init(status: NWPath.Status) {
        switch status {
        case .satisfied:
            self = .satisfied
        case .unsatisfied:
            self = .unsatisfied
        case .requiresConnection:
            self = .requiresConnection
        @unknown default:
            self = .unsatisfied
        }
    }
}

@available(iOS 12.0, *)
extension ConnectivityInterface {
    init(interface: NWInterface) {
        name = interface.name
        type = String(describing: interface.type)
    }
}

@available(iOS 12.0, *)
extension ConnectivityPath {
    init(path: NWPath) {
        status = ConnectivityStatus(status: path.status)
        availableInterfaces = path.availableInterfaces.map { ConnectivityInterface(interface: $0) }
        isExpensive = path.isExpensive
        supportsDNS = path.supportsDNS
        supportsIPv4 = path.supportsIPv4
        supportsIPv6 = path.supportsIPv6
    }
}

@available(iOS 12.0, *)
class DefaultNetworkMonitor: NetworkMonitor {
    private var monitor: NWPathMonitor?
    private var pathUpdateQueue: DispatchQueue?
    private var pathUpdateHandler: PathUpdateHandler?

    private let queue = DispatchQueue(label: "com.acme.connectivity.network-monitor", qos: .background)

    @available(iOS 12.0, *)
    func start(pathUpdateQueue: DispatchQueue, pathUpdateHandler: @escaping PathUpdateHandler) {
        // A new instance is required each time a monitor is started
        self.pathUpdateQueue = pathUpdateQueue
        self.pathUpdateHandler = pathUpdateHandler
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = didUpdate(path:)
        monitor.start(queue: queue)
        self.monitor = monitor
    }

    @available(iOS 12.0, *)
    func cancel() {
        guard let monitor = monitor else { return }
        monitor.cancel()
    }

    @available(iOS 12.0, *)
    func didUpdate(path: NWPath) {
        guard let pathUpdateHandler = pathUpdateHandler,
            let pathUpdateQueue = pathUpdateQueue else { return }
        let connectivityPath = ConnectivityPath(path: path)
        pathUpdateQueue.async {
            pathUpdateHandler(connectivityPath)
        }
    }
}
