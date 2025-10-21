//
//  DashboardView.swift
//  NodeDesk
//
//  Created by Jannik Hegemann on 21.10.25.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @Binding var servers: [StoredServer]
    @State private var editingServer: StoredServer? = nil
    @State private var connectingServer: StoredServer? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("Server Dashboard")
                .font(.largeTitle)
                .bold()

            // 🔹 Gesamtstatistik
            HStack(spacing: 30) {
                StatCard(title: "Gesamt", count: 14, color: Color.blue)
                StatCard(title: "Verbunden", count: 6, color: .green)
                StatCard(title: "Fehler", count: 1, color: .red)
                StatCard(title: "Offline", count: 5, color: .orange)
            }
            .padding(.horizontal)

            // 🔹 Pie Chart Status
            PieChartView(servers: servers)
                .frame(height: 200)
                .padding(.horizontal)

            // 🔹 Liste aller Server
            ScrollView {
                VStack(spacing: 10) {
                    ForEach($servers) { $server in
                        DashboardServerRowView(
                            server: $server,
                            onEdit: { s in editingServer = s }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
