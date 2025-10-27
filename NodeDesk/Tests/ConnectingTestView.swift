//
//  ConnectingTestView.swift
//  NodeDesk
//
//  Created by Hegemann, Jannik on 21.10.25.
//

import SwiftUI

struct ConnectingTestView: View {
    @Binding var server: Server
    @State private var currentState: ConnectState = .idle

    @State private var showDashboard: Bool = false
    @State private var showLogin: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            if !showDashboard {
                ConnectingView(state: $currentState, server: $server)
            } else {
                DashboardView()
            }
        }.onAppear(perform: runDemoStates)
            .sheet(isPresented: $showLogin) {
                LoginView(showLogin: $showLogin, currentState: $currentState, server: $server)
            }
    }

    /// Läuft alle States durch und verbindet bei fetchingData
    private func runDemoStates() {
        Task {
            let states = ConnectState.allCases
            var delay: Double = 0

            for state in states {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                
                await MainActor.run {
                    currentState = state
                }
                
                if state == .connecting {
                    // Warten, bis UI den State aktualisiert hat
                    try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 Sekunde
                    
                    let reachable = await withCheckedContinuation { continuation in
                        ProxmoxProvider.shared.checkAPIReachability(server: server) { reachable in
                            continuation.resume(returning: reachable)
                        }
                    }
                    
                    if reachable {
                        await MainActor.run {
                            currentState = .authenticating
                        }
                    } else {
                        await MainActor.run {
                            currentState = .failed
                        }
                        break
                    }
                }
                
                if state == .authenticating {
                    showLogin = true
                    // Warten, bis der State sich ändert
                    while currentState == .authenticating {
                        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 Sekunde
                    }
                }
                
                if(currentState == .fetchingData) {
                    var gettedCluster: Bool = false
                    var gettedNodes: Bool = false
                    var gettedVMs: Bool = false
                    
                    // Get Cluster & Nodes
                    ProxmoxProvider.shared.sendAuthenticatedRequest(to: "/cluster/status", server: server) { result in
                        print(result)
                        
                        guard let result = result, !result.isEmpty else {
                            currentState = .failed
                            return
                        }
                        
                        // String -> Data
                        guard let jsonData = result.data(using: .utf8) else {
                            currentState = .failed
                            return
                        }
                        
                        if let responseDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                           let data = responseDict["data"] as? [[String: Any]] {
                            
                            // Getting Cluster
                            if let cluster = data.first(where: { ($0["type"] as? String) == "cluster" }) {
                                ProxmoxCache.shared.cache(ProxmoxCluster(
                                    id: cluster["id"] as! String,
                                    name: cluster["name"] as! String
                                ))
                            }
                            gettedCluster = true

                            // Getting Nodes
                            let nodes = data.filter { ($0["type"] as? String) == "node" }
                            for node in nodes {
                                ProxmoxCache.shared.cache(ProxmoxNode(
                                    id: node["nodeid"] as! Int,
                                    name: node["name"] as! String,
                                    ip: node["ip"] as? String ?? "",
                                    status: node["online"] as? Int == 1 ? "online" : "offline"
                                ))
                            }
                        } else {
                            currentState = .failed
                        }
                    }
                    
                    // Get Node Details
                    ProxmoxProvider.shared.sendAuthenticatedRequest(to: "/cluster/resources?type=node", server: server) { result in
                        guard let result = result, !result.isEmpty else {
                            currentState = .failed
                            return
                        }
                        
                        // String -> Data
                        guard let jsonData = result.data(using: .utf8) else {
                            currentState = .failed
                            return
                        }
                        
                        if let responseDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                           let data = responseDict["data"] as? [[String: Any]] {
                            // Getting Nodes
                            let nodes = data.filter { ($0["type"] as? String) == "node" }
                            for node in nodes {
                                var nodeVar = ProxmoxCache.shared.get(node: node["node"] as! String)
                                // Set CPU data
                                nodeVar?.cpu = Float(node["cpu"] as? Double ?? 0.0)
                                nodeVar?.maxcpu = node["maxcpu"] as? Int ?? 0
                                
                                // Set Memory data
                                nodeVar?.memory = node["mem"] as? Int ?? 0
                                nodeVar?.maxmemory = node["maxmem"] as? Int ?? 0
                                
                                // Set Disk data
                                nodeVar?.disk = node["disk"] as? Int ?? 0
                                nodeVar?.maxdisk = node["maxdisk"] as? Int ?? 0
                                
                                // Set Uptime data
                                nodeVar?.uptime = node["uptime"] as? Int ?? 0
                                ProxmoxCache.shared.cache(nodeVar!)
                            }
                            gettedNodes = true
                        } else {
                            currentState = .failed
                        }
                    }
                    
                    // Get VM Details
                    ProxmoxProvider.shared.sendAuthenticatedRequest(to: "/cluster/resources?type=vm", server: server) { result in
                        guard let result = result, !result.isEmpty else {
                            currentState = .failed
                            return
                        }
                        
                        // String -> Data
                        guard let jsonData = result.data(using: .utf8) else {
                            currentState = .failed
                            return
                        }
                        
                        if let responseDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                           let data = responseDict["data"] as? [[String: Any]] {
                            // Getting Nodes
                            let vms = data.filter { ($0["type"] as? String) == "qemu" }
                            for vm in vms {
                                ProxmoxCache.shared.cache(ProxmoxVM(
                                    id: vm["vmid"] as! Int,
                                    name: vm["name"] as! String,
                                    node: vm["node"] as! String,
                                    status: vm["status"] as! String,
                                    cpu: Float(vm["cpu"] as! Double),
                                    maxcpu: vm["maxcpu"] as! Int,
                                    memory: vm["memory"] as! Int,
                                    maxmemory: vm["maxmemory"] as! Int,
                                    disk: vm["disk"] as! Int,
                                    maxdisk: vm["maxdisk"] as! Int,
                                    uptime: vm["uptime"] as! Int
                                ))
                            }
                            gettedNodes = true
                        } else {
                            currentState = .failed
                        }
                    }
                    
                    if(gettedCluster && gettedNodes && gettedVMs) {
                        currentState = .success
                    }
                }
                
                if currentState == .failed {
                    break
                }
                
                if currentState == .success {
                    showDashboard = true
                    break
                }
                
                delay = 1.5
            }
        }
    }
}
