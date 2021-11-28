import SwiftUI
import ConnectivityKit

extension Color {
    static let background = Color("Background")
}

struct MainView: View {
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        GeometryReader { p in
            ZStack {
                VStack {
                    Text(environment.networkEmoji)
                        .font(.system(size: 120.0))
                    Text(environment.networkStatus)
                        .font(.title)
                }
                VStack {
                    Spacer()
                    Text(environment.pathStatus)
                        .font(.caption)
                    Text(environment.interfaces)
                        .font(.caption2)
                }
                .padding()
            }
            .frame(width: p.size.width, height: p.size.height)
            .frame(minWidth: 200, minHeight: 200)
            .background(Color.background)
            .onChange(of: scenePhase) {
                switch $0 {
                case .background:
                    environment.stopMonitor()
                case .active:
                    environment.startMonitor()
                default:
                    return
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let interface = ConnectivityInterface(name: "en0", type: .wifi)
        let onlineEnv = AppEnvironment()
        let offlineEnv = AppEnvironment()
        let onlinePath = ConnectivityPath(status: .satisfied, availableInterfaces: [interface])
        let offlinePath = ConnectivityPath(status: .unsatisfied, availableInterfaces: [])
        onlineEnv.handlePathUpdate(path: onlinePath)
        offlineEnv.handlePathUpdate(path: offlinePath)
        return Group {
            MainView()
                .environmentObject(onlineEnv)
                .preferredColorScheme(.dark)
            MainView()
                .environmentObject(offlineEnv)
                .preferredColorScheme(.light)

        }
    }
}
