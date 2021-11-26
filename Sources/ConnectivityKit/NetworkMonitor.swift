import Foundation
import Network

@available(iOS 12.0, macOS 10.14, tvOS 12.0, watchOS 6.0, *)
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

@available(iOS 12.0, macOS 10.14, tvOS 12.0, watchOS 6.0, *)
extension ConnectivityInterfaceType {
    init(interfaceType: NWInterface.InterfaceType) {
        switch interfaceType {
            case .other:
                self = .other
            case .wifi:
                self = .wifi
            case .cellular:
                self = .cellular
            case .wiredEthernet:
                self = .wiredEthernet
            case .loopback:
                self = .loopback
        @unknown default:
            self = .other
        }
    }
}

@available(iOS 12.0, macOS 10.14, tvOS 12.0, watchOS 6.0, *)
extension ConnectivityInterface {
    init(interface: NWInterface) {
        name = interface.name
        type = ConnectivityInterfaceType(interfaceType: interface.type)
    }
}

@available(iOS 12.0, macOS 10.14, tvOS 12.0, watchOS 6.0, *)
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

@available(iOS 12.0, macOS 10.14, tvOS 12.0, watchOS 6.0, *)
class NetworkMonitor: AnyConnectivityMonitor {
    private var monitor: NWPathMonitor?
    private var pathUpdateQueue: DispatchQueue?
    private var pathUpdateHandler: PathUpdateHandler?

    private let queue = DispatchQueue(label: "com.acme.connectivity.network-monitor", qos: .background)

    @available(iOS 12.0, macOS 10.14, tvOS 12.0, watchOS 6.0, *)
    func start(pathUpdateQueue: DispatchQueue, pathUpdateHandler: @escaping PathUpdateHandler) {
        self.pathUpdateQueue = pathUpdateQueue
        self.pathUpdateHandler = pathUpdateHandler
        // A new instance is required each time a monitor is started
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = didUpdate(path:)
        monitor.start(queue: queue)
        self.monitor = monitor
    }

    @available(iOS 12.0, macOS 10.14, tvOS 12.0, watchOS 6.0, *)
    func cancel() {
        guard let monitor = monitor else { return }
        monitor.cancel()
    }

    @available(iOS 12.0, macOS 10.14, tvOS 12.0, watchOS 6.0, *)
    func didUpdate(path: NWPath) {
        guard let pathUpdateHandler = pathUpdateHandler,
            let pathUpdateQueue = pathUpdateQueue else { return }
        let connectivityPath = ConnectivityPath(path: path)
        pathUpdateQueue.async {
            pathUpdateHandler(connectivityPath)
        }
    }
}
