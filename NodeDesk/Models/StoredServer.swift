//
//  StoredServer.swift
//  NodeDesk
//
//  Created by Jannik Hegemann on 21.10.25.
//

import SwiftUI

struct StoredServer: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var address: [String]
    var type: ServerType
    var os: OperationSystem
}

enum ServerType: String, CaseIterable {
    case DOMAIN_CONTROLLER = "Domain Controller"
    case APPLICATION_SERVER = "Application Server"
    case SQL_SERVER = "SQL Server"
    case ROUTER_SERVER = "Router Server"
    case DOCKER_SERVER = "Docker Server"
    case OTHER = "Anderes"
    
    init?(key: String) {
            // Suche den Case mit dem passenden Namen
            if let matchingCase = ServerType.allCases.first(where: { "\($0)" == key }) {
                self = matchingCase
            } else {
                return nil
            }
        }
}

enum OperationSystem: String, CaseIterable {
    case WINDOWS_2019 = "Windows 2019"
    case WINDOWS_2022 = "Windows 2022"
    case WINDOWS_2025 = "Windows 2025"
    case LINUX_DEBIAN = "Linux (Debian)"
    case LINUX_UBUNTU = "Linux (Ubuntu)"
    case UNIX = "Unix"
    case OTHER = "Anderes"
    
    init?(key: String) {
            // Suche den Case mit dem passenden Namen
            if let matchingCase = OperationSystem.allCases.first(where: { "\($0)" == key }) {
                self = matchingCase
            } else {
                return nil
            }
        }
}
