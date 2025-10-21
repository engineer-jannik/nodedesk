//
//  ServerListView.swift
//  NodeDesk
//
//  Created by Hegemann, Jannik on 21.10.25.
//

import SwiftUI

// MARK: - Haupt-View
struct ServerListView: View {
    @Binding var isConnecting: Server
    @Binding var isConnected: Server
    @StateObject private var store = ServerStore()
    @State private var showingAddSheet = false
    @State private var editingServer: Server? = nil

    var body: some View {
            NavigationView {
                VStack {
                    // 🔍 Suchfeld + Sortierbutton
                    HStack {
                        TextField("Server suchen…", text: $store.searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)

                        Button {
                            store.toggleSortOrder()
                        } label: {
                            Label("Sortieren", systemImage: store.sortAscending ? "arrow.up" : "arrow.down")
                        }
                        .help("Sortierreihenfolge umschalten")
                        .padding(.trailing)
                    }
                    .padding(.top)

                    // 📋 Liste
                    List {
                        ForEach(store.filteredServers) { server in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(server.name)
                                        .font(.headline)
                                    Text(server.address)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                // 🔌 Connect
                                Button {
                                    connect(to: server)
                                } label: {
                                    Image(systemName: "bolt.horizontal.circle")
                                        .imageScale(.large)
                                        .foregroundColor(.green)
                                }
                                .buttonStyle(.plain)
                                .help("Mit Server verbinden")

                                // ✏️ Bearbeiten
                                Button {
                                    editingServer = server
                                } label: {
                                    Image(systemName: "pencil.circle")
                                        .imageScale(.large)
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(.plain)
                                .help("Server bearbeiten oder löschen")
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.inset)
                }
                .navigationTitle("Serverliste")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingAddSheet = true
                        } label: {
                            Label("Server hinzufügen", systemImage: "plus")
                        }
                    }
                }
                // 🔧 Sheets
                .sheet(isPresented: $showingAddSheet) {
                    EditServerView { newServer in
                        store.addServer(newServer)
                    }
                }
                .sheet(item: $editingServer) { server in
                    EditServerView(server: server, allowDelete: true) { updatedServer in
                        store.updateServer(updatedServer)
                    } onDelete: {
                        if let index = store.servers.firstIndex(of: server) {
                            store.servers.remove(at: index)
                        }
                    }
                }
            }
            .frame(minWidth: 480, minHeight: 350)
        }

        // MARK: - Simulierter Connect-Handler
        func connect(to server: Server) {
            isConnecting = server
            print("🔌 Verbinde zu \(server.name) @ \(server.address)")
            // Hier könntest du z. B. eine echte SSH-, Socket- oder API-Verbindung starten
        }
    }

// MARK: - Server hinzufügen / bearbeiten
struct EditServerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var server: Server
    var allowDelete: Bool = false
    var onSave: (Server) -> Void
    var onDelete: (() -> Void)? = nil

    init(server: Server? = nil,
         allowDelete: Bool = false,
         onSave: @escaping (Server) -> Void,
         onDelete: (() -> Void)? = nil) {
        _server = State(initialValue: server ?? Server(name: "", address: ""))
        self.allowDelete = allowDelete
        self.onSave = onSave
        self.onDelete = onDelete
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Section("Serverinformationen") {
                TextField("Servername", text: $server.name)
                TextField("Adresse", text: $server.address)
            }
            
            Section("Datenbank-Login") {
                TextField("Benutzername", text: $server.dbuser)
                SecureField("Passwort", text: $server.dbpassword)
            }

            HStack {
                if allowDelete {
                    Button(role: .destructive) {
                        onDelete?()
                        dismiss()
                    } label: {
                        Label("Löschen", systemImage: "trash")
                    }
                    Spacer()
                } else {
                    Spacer()
                }

                Button("Abbrechen") { dismiss() }
                Button("Speichern") {
                    onSave(server)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 320)
    }
}
