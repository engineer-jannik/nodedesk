//
//  DashboardServerRowCiew.swift
//  NodeDesk
//
//  Created by Jannik Hegemann on 21.10.25.
//

import SwiftUI

struct DashboardServerRowView: View {
    @Binding var server: StoredServer
    var onEdit: (StoredServer) -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(server.name)
                    .font(.headline)
                Text("\(server.name) • Status: ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("OS: \(server.os.rawValue) • \(server.type.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()

            Button {
                onEdit(server)
            } label: {
                Image(systemName: "pencil.circle")
                    .imageScale(.large)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
        .padding(.horizontal)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
}
