//
//  ConnectivityApp.swift
//  Connectivity
//
//  Created by Stehling, Brennan on 6/25/21.
//

import SwiftUI

@main
struct ConnectivityApp: App {
    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(AppEnvironment())
        }
    }
}
