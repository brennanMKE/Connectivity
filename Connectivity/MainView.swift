import SwiftUI

struct MainView: View {
    @EnvironmentObject var environment: AppEnvironment
    
    var body: some View {
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
        }
        .onAppear {
            environment.startMonitor()
        }
        .onDisappear {
            environment.stopMonitor()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
