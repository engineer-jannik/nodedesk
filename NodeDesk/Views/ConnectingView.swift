//
//  ConnectingView.swift
//  NodeDesk
//
//  Created by Hegemann, Jannik on 21.10.25.
//

import SwiftUI

struct ConnectingView: View {
    @Binding var state: ConnectState
    @Binding var server: Server

    var body: some View {
        VStack(spacing: 20) {
            Text("Verbinde zu")
                .font(.title3)
            VStack {
                Text(server.name)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                Text(server.address)
                    .font(.subheadline)
            }

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: 250)

            Text(state.rawValue)
                .font(.headline)
                .foregroundColor(state == .failed ? .red : .primary)

            if state == .success {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.green)
            } else if state == .failed {
                Image(systemName: "xmark.octagon.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .frame(width: 400, height: 300)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 10)
    }

    private var progress: Double {
        switch state {
        case .idle: return 0
        case .connecting: return 0.25
        case .authenticating: return 0.5
        case .fetchingData: return 0.75
        case .success: return 1.0
        case .failed: return 1.0
        }
    }
}
