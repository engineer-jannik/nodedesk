//
//  ConnectState.swift
//  NodeDesk
//
//  Created by Hegemann, Jannik on 21.10.25.
//

enum ConnectState: String, CaseIterable {
    case idle = "Bereit"
    case connecting = "Verbinden..."
    case authenticating = "Authentifiziere..."
    case fetchingData = "Hole Daten..."
    case success = "Verbindung erfolgreich ✅"
    case failed = "Verbindung fehlgeschlagen ❌"
}
