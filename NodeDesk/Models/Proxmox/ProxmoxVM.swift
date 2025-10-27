//
//  ProxmoxServer.swift
//  NodeDesk
//
//  Created by Hegemann, Jannik on 22.10.25.
//

struct ProxmoxVM: Codable {
    let id: Int
    let name: String
    var node: String
    var status: String = ""
    var cpu: Float = 0.0
    var maxcpu: Int = 0
    var memory: Int = 0
    var maxmemory: Int = 0
    var disk: Int = 0
    var maxdisk: Int = 0
    var uptime: Int = 0
    var tags: [String] = []
    
    func uptimeFormatted() -> String {
            let totalSeconds = uptime
            let days = totalSeconds / 86_400
            let hours = (totalSeconds % 86_400) / 3_600
            let minutes = (totalSeconds % 3_600) / 60
            let seconds = totalSeconds % 60
            
            var parts: [String] = []
            if days > 0 { parts.append("\(days)d") }
            if hours > 0 || days > 0 { parts.append("\(hours)h") }
            if minutes > 0 || hours > 0 || days > 0 { parts.append("\(minutes)m") }
            else { parts.append("\(seconds)s") }
            
            return parts.joined(separator: " ")
        }
}
