import Foundation
import Reachability

extension ConnectivityStatus {
    
    init(networkStatus: NetworkStatus) {
        switch networkStatus {
        case .notReachable:
            self = .unsatisfied
        case .reachableViaWiFi, .reachableViaWWAN:
            self = .satisfied
        @unknown default:
            self = .unsatisfied
        }
    }
}

extension ConnectivityPath {

    init(networkStatus: NetworkStatus, connectionRequired: Bool) {
        status = ConnectivityStatus(networkStatus: networkStatus)
        availableInterfaces = []
        isExpensive = networkStatus == .reachableViaWWAN
        supportsDNS = false
        supportsIPv4 = false
        supportsIPv6 = false
    }
}

public class ReachabilityMonitor: AnyConnectivityMonitor {
    var reachability: Reachability?
    private var pathUpdateQueue: DispatchQueue?
    private var pathUpdateHandler: PathUpdateHandler?

    var hostname: String {
        let result = Bundle.main.infoDictionary?["ReachabilityHostname"] as? String ?? "github.com"
        return result
    }

    public func start(pathUpdateQueue: DispatchQueue, pathUpdateHandler: @escaping PathUpdateHandler) {
        debugPrint(#function)
        self.pathUpdateQueue = pathUpdateQueue
        self.pathUpdateHandler = pathUpdateHandler
        let reachability = Reachability(hostname: hostname)
        reachability.didChangeHandler = didChange(reachability:)
        reachability.start()
        self.reachability = reachability
    }

    public func cancel() {
        debugPrint(#function)
        guard let reachability = reachability else { return }
        reachability.cancel()
        self.reachability =  nil
    }

    func didChange(reachability: Reachability) {
        debugPrint(#function)
        guard let pathUpdateHandler = pathUpdateHandler,
            let pathUpdateQueue = pathUpdateQueue else { return }
        let connectivityPath = ConnectivityPath(networkStatus: reachability.currentStatus, connectionRequired: reachability.connectionRequired)
        debugPrint("\(connectivityPath)")
        pathUpdateQueue.async {
            pathUpdateHandler(connectivityPath)
        }
    }
}
