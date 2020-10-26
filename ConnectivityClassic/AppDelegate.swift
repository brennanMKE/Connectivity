import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let appState = AppState()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        debugPrint(#function)
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        debugPrint(#function)
        appState.startMonitor()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        debugPrint(#function)
        appState.stopMonitor()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        debugPrint(#function)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        debugPrint(#function)
    }
}
