import SwiftUI

@main
struct ConnectivityApp: App {
    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(AppEnvironment())
        }
    }
}
