//
//  Server.swift
//  NodeDesk
//
//  Created by Hegemann, Jannik on 21.10.25.
//

import SwiftUI

// MARK: - Datenmodell
struct Server: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var address: String
    var dbuser: String = ""
    var dbpassword: String = ""
}
