//
//  NodeDeskApp.swift
//  NodeDesk
//
//  Created by Hegemann, Jannik on 21.10.25.
//

import SwiftUI

@main
struct NodeDeskApp: App {
    @State private var isLoggedIn = false
    @State private var isConnecting: Server = Server(name: "STARTUP_DEFAULT", address: "0.0.0.0")
    @State private var isConnected: Server = Server(name: "STARTUP_DEFAULT", address: "0.0.0.0")
    @State private var connectionError: String? = nil
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if !isLoggedIn && isConnecting.name == "STARTUP_DEFAULT" && isConnected.name == "STARTUP_DEFAULT" {
                    ServerListView(isConnecting: $isConnecting, isConnected: $isConnected)
                } else if isConnecting.name != "STARTUP_DEFAULT" {
                    ConnectingTestView(server: $isConnecting)
                } else if isLoggedIn {
                    EmptyView()
                }
            }
        }
    }
}
