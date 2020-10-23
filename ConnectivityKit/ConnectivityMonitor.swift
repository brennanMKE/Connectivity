import Foundation
import Network

public enum ConnectivityStatus: String {
    case satisfied
    case unsatisfied
    case requiresConnection

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

public struct ConnectivityInterface {
    public let name: String
    public let type: String

    init(interface: NWInterface) {
        name = interface.name
        type = String(describing: interface.type)
    }
}

public struct ConnectivityPath {
    public let status: ConnectivityStatus
    public let availableInterfaces: [ConnectivityInterface]
    public let isExpensive: Bool
    public let isConstrained: Bool
    public let supportsDNS: Bool
    public let supportsIPv4: Bool
    public let supportsIPv6: Bool

    init(path: NWPath) {
        status = ConnectivityStatus(status: path.status)
        availableInterfaces = path.availableInterfaces.map { ConnectivityInterface(interface: $0) }
        isExpensive = path.isExpensive
        isConstrained = path.isConstrained
        supportsDNS = path.supportsDNS
        supportsIPv4 = path.supportsIPv4
        supportsIPv6 = path.supportsIPv6
    }
}

public typealias PathUpdateHandler = (ConnectivityPath) -> Void

public class ConnectivityMonitor {
    private var monitor: NWPathMonitor?
    private let queue = DispatchQueue(label: "com.acme.connectivity", qos: .background)
    private var pathUpdateQueue: DispatchQueue?
    private var pathUpdateHandler: PathUpdateHandler?

    public init() {}

    public func start(queue: DispatchQueue, pathUpdateHandler: @escaping PathUpdateHandler) {
        self.pathUpdateHandler = pathUpdateHandler
        // A new instance is required each time a monitor is started
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = didUpdate(path:)
        monitor.start(queue: queue)
        self.pathUpdateQueue = queue
        self.monitor = monitor
    }

    public func cancel() {
        guard let monitor = monitor else { return }
        monitor.cancel()
    }

    private func didUpdate(path: NWPath) {
        guard let pathUpdateHandler = pathUpdateHandler,
            let pathUpdateQueue = pathUpdateQueue else { return }
        let connectivityPath = ConnectivityPath(path: path)
        pathUpdateQueue.async {
            pathUpdateHandler(connectivityPath)
        }
    }

}
