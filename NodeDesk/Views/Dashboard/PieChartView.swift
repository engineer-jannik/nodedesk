//
//  PieChartView.swift
//  NodeDesk
//
//  Created by Jannik Hegemann on 21.10.25.
//

import SwiftUI
import Charts

struct PieChartView: View {
    let servers: [StoredServer]

    var body: some View {
        let data: [PieSlice] = [
            PieSlice(status: "Verbunden", count: 3, color: .green),
            PieSlice(status: "Fehler", count: 1, color: .red),
            PieSlice(status: "Offline", count: 6, color: .orange)
        ]

        Chart(data) { slice in
            SectorMark(
                angle: .value("Count", slice.count),
                innerRadius: .ratio(0.5),
                angularInset: 1
            )
            .foregroundStyle(slice.color)
        }
        .chartLegend(.visible)
    }
}

struct PieSlice: Identifiable {
    let id = UUID()
    let status: String
    let count: Int
    let color: Color
}
