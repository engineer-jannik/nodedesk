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

    var body: some View {
        VStack {
            ConnectingView(state: $currentState, server: $server)

            Button("Alle States durchlaufen") {
                runDemoStates()
            }
            .padding(.top)
        }
    }

    func runDemoStates() {
        let states = ConnectState.allCases
        var delay = 0.0

        for state in states {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                currentState = state
            }
            delay += 1.5
        }
    }
}
