# Connectivity

Modern networking with mobile devices has requirements which are unique from what was necessary with desktops and laptops which connected with Ethernet or WiFi networks years ago when the Reachability API was first used. In 2018, Apple introduced the Network Framework to provide additional features which are missing from Reachability. 

* [Network Framework]

For an introduction to network path monitoring with Network Framework see [Introduction to Network.framework] which was presented in 2018 at WWDC. Jump ahead to 50:00 for the section on network path monitoring.

## Swift Package

This project is set up as a Swift Package which can be used by the [Swift Package Manager] (SPM) with Xcode. In your `Package.swift` add this package with the code below.

```swift
dependencies: [
    .package(url: "https://github.com/brennanMKE/Connectivity", from: "1.0.0"),
],
```

## Development

Open the Xcode workspace to open both the app project and Swift Package and select and iOS profile to build. To run on a device configure code signing for your team.

## Legacy Version

See the [Legacy Version] for a demo of 2 apps. One supports iOS 13 and later and other can be run on devices running iOS version before iOS 12 to demonstrate how the Reachability implementation works.

## Supporting iOS 11.0 and 13.0

In the package there are demo app which both use the ConnectivityKit package which uses the modern Network framework for iOS 12 and later and for earlier releases it uses Reachability. Since the Network framework is only available with iOS 12 and later this code uses the `#available` and `@available` features of Swift to limit access to the code which requires the modern framework. A protocol is used to provide a common API for the implementations created with Network.framework and the legacy Reachability SDK so that the best available implementation is created with the code below.

For an app which supports iOS 11 or earlier the Reachability implementation would be used on devices running these earlier OS versions. You can see from stats showing on the [App Store Support Page] that the vast majority of users are running a current iOS version which would use the modern Network framework. A small percentage would get the Reachability alternative implementation.

```swift
public typealias PathUpdateHandler = (ConnectivityPath) -> Void

public protocol AnyConnectivityMonitor {
    func start(pathUpdateQueue: DispatchQueue,
               pathUpdateHandler: @escaping PathUpdateHandler)
    func cancel()
}

private func createMonitor() -> AnyConnectivityMonitor {
    let result: AnyConnectivityMonitor
    if #available(iOS 12.0, *) {
        result = NetworkMonitor()
    } else {
        result = ReachabilityMonitor()
    }
    return result
}
```

---
[Network Framework]: https://developer.apple.com/documentation/network
[Introduction to Network.framework]: https://developer.apple.com/videos/play/wwdc2018/715
[App Store Support Page]: https://developer.apple.com/support/app-store/
[Swift Package Manager]: https://swift.org/package-manager/
[Legacy Version]: https://github.com/brennanMKE/Connectivity/tree/legacy