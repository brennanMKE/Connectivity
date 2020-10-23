import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
       VStack {
            Spacer()
            Text(appState.networkEmoji)
                .font(.custom("San Francisco", size: 100))
            Text(appState.networkStatus)
                .fontWeight(.heavy)
            Spacer()
            Text(appState.pathStatus)
            Text(appState.interfaces)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView().environmentObject(AppState().preview())
    }
}
