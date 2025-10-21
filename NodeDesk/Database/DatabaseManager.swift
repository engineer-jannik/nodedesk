//
//  DatabaseManager.swift
//  NodeDesk
//
//  Created by Jannik Hegemann on 21.10.25.
//

import Foundation
import PostgresKit
import Logging
import NIO

/// Globale, dynamische Datenbank für macOS App
final class DatabaseManager {
    static let shared = DatabaseManager()

    private var eventLoopGroup: EventLoopGroup?
    private var pool: EventLoopGroupConnectionPool<PostgresConnectionSource>?
    private let logger = Logger(label: "app.database")
    private(set) var isConnected = false
    private(set) var currentServer: Server?

    private init() {}

    /// Verbindung zu einem Server aufbauen
    /// Rückgabe: true = erfolgreich, false = fehlgeschlagen
    @discardableResult
    func connect(to server: Server) async -> Bool {
        // Trenne alte Verbindung, falls vorhanden
        if isConnected {
            disconnect()
        }

        currentServer = server

        let configuration = SQLPostgresConfiguration(
            hostname: server.address,
            port: 5432,
            username: server.dbuser,
            password: server.dbpassword,
            database: "nodedesk-test",
            tls: .disable
        )

        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let source = PostgresConnectionSource(sqlConfiguration: configuration)
        let pool = EventLoopGroupConnectionPool(source: source, on: group)

        self.eventLoopGroup = group
        self.pool = pool

        do {
            let db = pool.database(logger: logger)
            let rows = try await db.simpleQuery("SELECT version();").get()
            if let version = rows.first?.column("version")?.string {
                print("✅ Verbunden mit PostgreSQL \(version) auf \(server.address)")
            }
            isConnected = true
            return true
        } catch {
            print("❌ Fehler beim Verbinden mit \(server.address): \(error)")
            disconnect()
            return false
        }
    }
    
    /// Holt die gespeicherten Server aus der Datenbank
    func fetchingServers() async -> [StoredServer] {
        guard let pool = pool else { return [] }
        var results: [StoredServer] = []
        do {
            let db = pool.database(logger: logger)
            let rows = try await db.simpleQuery("SELECT * FROM servers;").get()
            for row in rows {
                let idString: String? = row.column("id")?.string
                let name: String? = row.column("name")?.string
                let addressCSV: String? = row.column("address")?.string
                let type: String? = row.column("type")?.string?.replacingOccurrences(of: " ", with: "")
                let os: String? = row.column("os")?.string?.replacingOccurrences(of: " ", with: "")

                print(type)
                print(os)
                
                if let idString = idString,
                   let id = UUID(uuidString: idString),
                   let name = name,
                   let type = ServerType.init(key: type ?? "OTHER"),
                   let os = OperationSystem.init(key: os ?? "OTHER"),
                   let addressCSV = addressCSV {
                    // Split comma-separated addresses into a trimmed, non-empty list
                    let addresses: [String] = addressCSV
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }

                    results.append(StoredServer(id: id, name: name, address: addresses, type: type, os: os))
                } else {
                    continue
                }
            }
        } catch {
            print("❌ Fehler beim Fetchen der Daten aus der Tabelle \"servers\": \(error)")
        }
        return results
    }

    /// Allgemeine Abfrage
    func query(_ sql: String) async -> [PostgresRow] {
        guard let pool = pool else { return [] }

        do {
            let db = pool.database(logger: logger)
            return try await db.simpleQuery(sql).get()
        } catch {
            print("❌ Query-Fehler: \(error)")
            return []
        }
    }

    /// Connection trennen
    func disconnect() {
        do {
            try pool?.syncShutdownGracefully()
            try eventLoopGroup?.syncShutdownGracefully()
            print("🛑 Verbindung zu \(currentServer?.address ?? "Server") geschlossen.")
        } catch {
            print("⚠️ Fehler beim Trennen der Verbindung: \(error)")
        }

        pool = nil
        eventLoopGroup = nil
        isConnected = false
        currentServer = nil
    }
}

