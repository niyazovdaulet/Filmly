//
//  FilmlyApp.swift
//  Filmly
//
//  Created by Daulet on 12/07/2025.
//

import SwiftUI

@main
struct FilmlyApp: App {
    @StateObject private var networkMonitor = NetworkMonitor()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(networkMonitor)
                .onAppear {
                    networkMonitor.checkInitialConnection()
                }
                .alert("No Internet Connection", isPresented: $networkMonitor.showAlert) {
                    Button("OK") {
                        // Dismiss the alert
                    }
                } message: {
                    Text("This app requires an internet connection to function properly. Please check your network settings and try again.")
                }
        }
    }
}
