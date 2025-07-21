import Foundation
import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
    @Published var isConnected = false
    @Published var showAlert = false
    @Published var hasInitialized = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        startMonitoring()
    }
    
    deinit {
        monitor.cancel()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let isConnected = path.status == .satisfied
                self?.isConnected = isConnected
                self?.hasInitialized = true
                
                // Only show alert if we've initialized and connection is lost
                if self?.hasInitialized == true && !isConnected {
                    self?.showAlert = true
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    func checkInitialConnection() {
        // Only check after the monitor has had time to initialize
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.hasInitialized && !self.isConnected {
                self.showAlert = true
            }
        }
    }
} 