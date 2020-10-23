import Foundation

public enum ConnectivityStatus: String {
    case satisfied
    case unsatisfied
    case requiresConnection
}

public struct ConnectivityInterface {
    public let name: String
    public let type: String
}

public struct ConnectivityPath {
    public let status: ConnectivityStatus
    public let availableInterfaces: [ConnectivityInterface]
    public let isExpensive: Bool
    public let supportsDNS: Bool
    public let supportsIPv4: Bool
    public let supportsIPv6: Bool
}

public typealias PathUpdateHandler = (ConnectivityPath) -> Void

public protocol NetworkMonitor {
    func start(pathUpdateQueue: DispatchQueue, pathUpdateHandler: @escaping PathUpdateHandler)
    func cancel()
}

public class ConnectivityMonitor {
    private var networkMonitor: NetworkMonitor?
    private let queue = DispatchQueue(label: "com.acme.connectivity", qos: .background)

    public init() {}

    public func start(pathUpdateQueue: DispatchQueue, pathUpdateHandler: @escaping PathUpdateHandler) {
        guard #available(iOS 12.0, *) else {
            debugPrint("OS version not supported: \(#function)")
            return
        }
        let networkMonitor = DefaultNetworkMonitor()
        networkMonitor.start(pathUpdateQueue: pathUpdateQueue, pathUpdateHandler: pathUpdateHandler)
        self.networkMonitor = networkMonitor
    }

    public func cancel() {
        guard #available(iOS 12.0, *) else {
            debugPrint("OS version not supported: \(#function)")
            return
        }
        guard let networkMonitor = networkMonitor else { return }
        networkMonitor.cancel()
    }

}
