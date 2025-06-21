//
//  NetworkMonitor.swift
//  Code taken from https://holyswift.app/how-to-monitor-network-in-swiftui/
//

import Foundation
import Network

@Observable
class NetworkMonitor {
    var isConnected = true
    
    private let networkMonitor = NWPathMonitor()
    
    init() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        
        networkMonitor.start(queue: DispatchQueue.global())
    }
}
