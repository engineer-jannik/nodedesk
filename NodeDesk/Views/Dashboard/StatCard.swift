//
//  StatCard.swift
//  NodeDesk
//
//  Created by Jannik Hegemann on 21.10.25.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let count: Int
    let color: Color

    var body: some View {
        VStack {
            Text("\(count)")
                .font(.title)
                .bold()
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(width: 80, height: 80)
        .background(color.opacity(0.2), in: RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 3)
    }
}
