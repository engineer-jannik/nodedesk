//
//  ServerStore.swift
//  NodeDesk
//
//  Created by Hegemann, Jannik on 21.10.25.
//

import SwiftUI
import Combine
import Foundation

// MARK: - ViewModel mit lokaler Speicherung + Sortierung + Suche
class ServerStore: ObservableObject {
    @Published var servers: [Server] = [] {
        didSet { saveServers() }
    }
    @Published var searchText: String = ""
    @Published var sortAscending: Bool = true

    private let fileURL: URL

    init() {
        // Application Support/NodeDesk/servers.json
        let fm = FileManager.default
        let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("NodeDesk", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("servers.json")

        loadServers()
    }

    // MARK: - CRUD
    func addServer(_ server: Server) {
        servers.append(server)
        sortServers()
    }

    func updateServer(_ server: Server) {
        if let index = servers.firstIndex(where: { $0.id == server.id }) {
            servers[index] = server
            sortServers()
        }
    }

    func deleteServer(at offsets: IndexSet) {
        servers.remove(atOffsets: offsets)
    }

    // MARK: - Suche + Sortierung
    var filteredServers: [Server] {
        let lowerSearch = searchText.lowercased()
        let results = servers.filter {
            lowerSearch.isEmpty ||
            $0.name.lowercased().contains(lowerSearch) ||
            $0.address.lowercased().contains(lowerSearch)
        }
        return sortAscending
            ? results.sorted { $0.name.lowercased() < $1.name.lowercased() }
            : results.sorted { $0.name.lowercased() > $1.name.lowercased() }
    }

    func toggleSortOrder() {
        sortAscending.toggle()
        sortServers()
    }

    private func sortServers() {
        servers.sort {
            sortAscending
                ? $0.name.lowercased() < $1.name.lowercased()
                : $0.name.lowercased() > $1.name.lowercased()
        }
    }

    // MARK: - Lokale Speicherung
    private func saveServers() {
        do {
            let data = try JSONEncoder().encode(servers)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("❌ Fehler beim Speichern der Serverdaten:", error)
        }
    }

    private func loadServers() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            servers = try JSONDecoder().decode([Server].self, from: data)
        } catch {
            print("❌ Fehler beim Laden der Serverdaten:", error)
            servers = []
        }
    }
}
