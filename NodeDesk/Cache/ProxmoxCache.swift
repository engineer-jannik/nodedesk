//
//  ProxmoxCache.swift
//  NodeDesk
//
//  Created by Jannik Hegemann on 25.10.25.
//

import Foundation

final class ProxmoxCache {
    static let shared = ProxmoxCache()
    private var clusterCache: [String: ProxmoxCluster] = [:]
    private var nodeCache: [String: ProxmoxNode] = [:]
    private var vmCache: [String: ProxmoxVM] = [:]
    
    func getAllCluster() -> [ProxmoxCluster] {
        Array(self.clusterCache.values)
    }
    
    func getAllNodes() -> [ProxmoxNode] {
        Array(self.nodeCache.values)
    }
    
    func get(cluster: String) -> ProxmoxCluster? {
        self.clusterCache[cluster]
    }
    
    func get(node: String) -> ProxmoxNode? {
        self.nodeCache[node]
    }
    
    func get(vm: String) -> ProxmoxVM? {
        self.vmCache[vm]
    }
    
    func getAllVMs() -> [ProxmoxVM] {
        Array(self.vmCache.values)
    }
    
    func cache(_ cluster: ProxmoxCluster) {
        self.clusterCache[cluster.name] = cluster
    }
    
    func cache(_ node: ProxmoxNode) {
        self.nodeCache[node.name] = node
    }
    
    func cache(_ vm: ProxmoxVM) {
        self.vmCache[vm.name] = vm
    }
    
    func remove(cluster: ProxmoxCluster) {
        self.clusterCache.removeValue(forKey: cluster.name)
    }
    
    func remove(node: ProxmoxNode) {
        self.nodeCache.removeValue(forKey: node.name)
    }
    
    func remove(vm: ProxmoxVM) {
        self.vmCache.removeValue(forKey: vm.name)
    }
    
    func removeAll() {
        self.clusterCache.removeAll()
        self.nodeCache.removeAll()
        self.vmCache.removeAll()
    }
}
