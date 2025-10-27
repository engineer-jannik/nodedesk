//
//  DashboardView.swift
//  NodeDesk
//
//  Created by Jannik Hegemann on 25.10.25.
//

import SwiftUI

// MARK: - TreeItem mit String ID
struct TreeItem: Identifiable {
    enum Kind {
        case cluster(cluster: ProxmoxCluster)
        case node(node: ProxmoxNode)
        case vm(vm: ProxmoxVM, nodeName: String)
    }
    
    let id: String
    let kind: Kind
    var children: [TreeItem]?
    
    var title: String {
        switch kind {
        case .cluster(let c): return c.name
        case .node(let n): return n.name
        case .vm(let vm, _): return vm.name
        }
    }
    
    var systemImageName: String {
        switch kind {
        case .cluster: return "network"
        case .node: return "server.rack"
        case .vm: return "play.circle.fill"
        }
    }
}

// MARK: - Tree Builder
func tree(from cluster: ProxmoxCluster, nodes: [ProxmoxNode], vms: [ProxmoxVM]) -> TreeItem {
    let nodeItems = nodes.map { node in
        let vmItems = vms.filter { $0.node == node.name }.map { vm in
            TreeItem(id: "\(vm.id)", kind: .vm(vm: vm, nodeName: node.name))
        }
        return TreeItem(id: "\(node.id)", kind: .node(node: node), children: vmItems)
    }
    return TreeItem(id: cluster.id, kind: .cluster(cluster: cluster), children: nodeItems)
}

// MARK: - Sidebar
struct ProxmoxSidebar: View {
    let root: TreeItem
    @Binding var selectedID: String?
    
    var body: some View {
        List(selection: $selectedID) {
            OutlineGroup([root], children: \.children) { item in
                Label(item.title, systemImage: item.systemImageName)
                    .tag(item.id)
            }
        }
        .navigationTitle("Proxmox")
        .listStyle(SidebarListStyle())
    }
}

// MARK: - Detail View Router
struct ProxmoxDetailView: View {
    let selectedID: String?
    let root: TreeItem
    
    func findItem(_ id: String?, in node: TreeItem) -> TreeItem? {
        guard let id = id else { return nil }
        if node.id == id { return node }
        if let children = node.children {
            for child in children {
                if let found = findItem(id, in: child) { return found }
            }
        }
        return nil
    }
    
    var body: some View {
        if let item = findItem(selectedID, in: root) {
            switch item.kind {
            case .cluster(let c):
                ClusterDetailView(cluster: c)
            case .node(let n):
                NodeDetailView(node: n)
            case .vm(let vm, let nodeName):
                VMDetailView(vm: vm, nodeName: nodeName)
            }
        } else {
            VStack {
                Text("Wähle ein Element aus der Liste.")
                    .foregroundColor(.secondary)
                    .font(.title3)
            }
        }
    }
}

// MARK: - Cluster Detail View
struct ClusterDetailView: View {
    let cluster: ProxmoxCluster
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Cluster: \(cluster.name)")
                .font(.largeTitle.bold())
        }
        .padding()
    }
}

struct NodeDetailView: View {
    let node: ProxmoxNode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(node.name)
                            .font(.largeTitle.bold())
                        Text(node.ip)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: node.status)
                }
                
                // Resource Overview
                VStack(spacing: 16) {
                    ResourceBarView(title: "CPU Usage", value: Double(node.cpu), max: 1.0, color: .blue)
                    ResourceBarView(title: "Memory Usage", value: Double(node.memory), max: Double(node.maxmemory), color: .green)
                    ResourceBarView(title: "Storage Usage", value: Double(node.disk), max: Double(node.maxdisk), color: .orange)
                }
                .padding()
                .background(.thinMaterial)
                .cornerRadius(16)
                .shadow(radius: 4)
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: { print("Restart Node") }) {
                        Label("Restart", systemImage: "arrow.clockwise.circle.fill")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    
                    Button(action: { print("Shutdown Node") }) {
                        Label("Shutdown", systemImage: "power.circle.fill")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                
                Divider().padding(.vertical, 10)
                
                // Node Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Node Details")
                        .font(.title2.bold())
                    Text("• Uptime: \(node.uptimeFormatted())")
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
            }
            .padding()
        }
        .navigationTitle("Node Details")
    }
}

// MARK: - Resource Bar View
struct ResourceBarView: View {
    let title: String
    let value: Double
    let max: Double
    let color: Color

    var percentage: Double {
        guard max > 0 else { return 0 }
        return value / max
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.1f%%", percentage * 100))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            ProgressView(value: percentage)
                .accentColor(color)
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: String

    var color: Color {
        switch status.lowercased() {
        case "online", "running": return .green
        case "offline", "stopped": return .red
        default: return .gray
        }
    }

    var body: some View {
        Text(status.capitalized)
            .font(.caption.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(10)
    }
}

// MARK: - VM Detail View
struct VMDetailView: View {
    let vm: ProxmoxVM
    let nodeName: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(vm.name)
                                .font(.largeTitle.bold())
                            Text("\(vm.uptimeFormatted())")
                                .font(.subheadline)
                            
                            Spacer()
                            StatusBadge(status: vm.status)
                        }
                        
                        HStack {
                            ForEach(vm.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption.bold())
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.gray.opacity(0.2))
                                    .foregroundColor(.gray)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                
                // Resource Overview
                VStack(spacing: 16) {
                    ResourceBarView(title: "CPU Usage", value: Double(vm.cpu), max: 1.0, color: .blue)
                    ResourceBarView(title: "Memory Usage", value: Double(vm.memory), max: Double(vm.maxmemory), color: .green)
                    ResourceBarView(title: "Storage Usage", value: Double(vm.disk), max: Double(vm.maxdisk), color: .orange)
                }
                .padding()
                .background(.thinMaterial)
                .cornerRadius(16)
                .shadow(radius: 4)
                
                Divider().padding(.vertical, 10)
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: { print("Start VM") }) {
                        Label("Start", systemImage: "arrowtriangle.forward.circle")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(vm.status == "online")
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    Button(action: { print("Restart VM") }) {
                        Label("Restart", systemImage: "arrow.clockwise.circle.fill")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(vm.status != "online")
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    Button(action: { print("Shutdown VM") }) {
                        Label("Shutdown", systemImage: "power.circle.fill")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(vm.status != "online")
                    .buttonStyle(.bordered)
                    .tint(.red)
                    
                    Button(action: { print("Stop VM") }) {
                        Label("Stop (Force)", systemImage: "stop.circle.fill")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(vm.status != "online")
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
            .padding()
        }
        .navigationTitle("VM Details")
    }
}

// MARK: - Main Dashboard
struct DashboardView: View {
    @State private var selectedID: String? = nil
    
    // Beispiel-Daten
    let cluster = ProxmoxCache.shared.getAllCluster().first!
    let nodes: [ProxmoxNode] = ProxmoxCache.shared.getAllNodes().sorted { $0.name < $1.name }
    let vms: [ProxmoxVM] = ProxmoxCache.shared.getAllVMs()
    
    private var rootItem: TreeItem {
        tree(from: cluster, nodes: nodes, vms: vms)
    }
    
    var body: some View {
        NavigationSplitView {
            ProxmoxSidebar(root: rootItem, selectedID: $selectedID)
        } detail: {
            ProxmoxDetailView(selectedID: selectedID, root: rootItem)
        }
    }
}
