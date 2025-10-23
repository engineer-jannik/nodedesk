//
//  ConnectingTestView.swift
//  NodeDesk
//
//  Created by Hegemann, Jannik on 21.10.25.
//

import SwiftUI

struct ConnectingTestView: View {
    @Binding var server: Server
    @State private var currentState: ConnectState = .idle

    @State private var showDashboard: Bool = false
    @State private var showLogin: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            if !showDashboard {
                ConnectingView(state: $currentState, server: $server)
            } 
        }.onAppear(perform: runDemoStates)
            .sheet(isPresented: $showLogin) {
                LoginView(showLogin: $showLogin, currentState: $currentState, server: $server)
            }
    }

    /// Läuft alle States durch und verbindet bei fetchingData
    private func runDemoStates() {
        Task {
            let states = ConnectState.allCases
            var delay: Double = 0

            for state in states {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                
                await MainActor.run {
                    currentState = state
                }
                
                if state == .connecting {
                    // Warten, bis UI den State aktualisiert hat
                    try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 Sekunde

                    let reachable = await withCheckedContinuation { continuation in
                        ProxmoxProvider.shared.checkAPIReachability(server: server) { reachable in
                            continuation.resume(returning: reachable)
                        }
                    }

                    if reachable {
                        await MainActor.run {
                            currentState = .authenticating
                        }
                    } else {
                        await MainActor.run {
                            currentState = .failed
                        }
                        break
                    }
                }
                
                if state == .authenticating {
                    showLogin = true
                    // Warten, bis der State sich ändert
                    while currentState == .authenticating {
                        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 Sekunde
                    }
                }
                
                if(currentState == .fetchingData) {
                    
                }

                if currentState == .failed {
                    break
                }
                
                delay = 1.5
            }
        }
    }
}
