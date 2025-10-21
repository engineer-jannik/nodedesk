//
//  ConnectingTestView.swift
//  NodeDesk
//
//  Created by Hegemann, Jannik on 21.10.25.
//

import SwiftUI

struct ConnectingTestView: View {
    @State private var currentState: ConnectState = .idle
    @Binding var server: Server

    @State private var fetchedServers: [StoredServer] = []
    @State private var showDashboard: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            if !showDashboard {
                ConnectingView(state: $currentState, server: $server)

                Button("Alle States durchlaufen") {
                    Task {
                        await runDemoStates()
                    }
                }
                .padding(.top)
            } else {
                DashboardView(servers: $fetchedServers)
            }
        }
    }

    /// Läuft alle States durch und verbindet bei fetchingData
    private func runDemoStates() async {
        let states = ConnectState.allCases
        var delay: Double = 0

        for state in states {
            // Warte die bisherige Verzögerung
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            
            // Update UI auf MainThread
            await MainActor.run {
                currentState = state
            }

            // Verbindung herstellen bei fetchingData
            if state == .connecting {
                if !(await connectToDatabase()) {
                    currentState = .failed
                    return
                }
            }
            
            if state == .fetchingData {
                let result = await DatabaseManager.shared.fetchingServers()
                await MainActor.run {
                    fetchedServers = result
                }
                result.forEach { _server in
                    print(_server)
                }
            }
            
            if state == .success {
                await MainActor.run {
                    showDashboard = true
                }
                return
            }

            delay = 1.5
        }
    }

    /// Datenbankverbindung aufbauen
    private func connectToDatabase() async -> Bool {
        await MainActor.run { currentState = .connecting }

        let success = await DatabaseManager.shared.connect(to: server)

        if success {
            return true
        } else {
            return false
        }
    }
}

