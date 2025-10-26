//
//  ProxmoxProvider.swift
//  NodeDesk
//
//  Created by Hegemann, Jannik on 22.10.25.
//

import Foundation

final class ProxmoxProvider {
    static let shared = ProxmoxProvider()
    private var pveAuthCookie: String?

    private init() {}
    
    // MARK: - API Reachability Check
    func checkAPIReachability(server: Server, completion: @escaping (Bool) -> Void) {
        let url = "https://\(server.address):8006/api2/json/"
                
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["curl", "-s", "-k", "-w", "%{http_code}", "--connect-timeout", "5", url]
        process.standardOutput = pipe
                
        do {
            try process.run()
        } catch {
            completion(false)
            return
        }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let statusCode = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if statusCode == "401" {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    // MARK: - Login
    func login(server: Server, completion: @escaping (Bool) -> Void) {
        let loginURL = "https://\(server.address):8006/api2/json/access/ticket"
        let body = "username=\(server.username)&password=\(server.password)"
        
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["curl", "-s", "-k", "--connect-timeout", "5", "-X", "POST", loginURL,
                             "-H", "Content-Type: application/x-www-form-urlencoded",
                             "--data", body]
        process.standardOutput = pipe
        
        do {
            try process.run()
        } catch {
            completion(false,)
            return
        }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let jsonString = String(data: data, encoding: .utf8),
              let jsonData = jsonString.data(using: .utf8) else {
            completion(false)
            return
        }
        
        print(jsonString)
                
        do {
            if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let data = json["data"] as? [String: Any],
               let ticket = data["ticket"] as? String {
                self.pveAuthCookie = ticket
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            completion(false)
        }
    }
    
    // MARK: - Authenticated Request
    func sendAuthenticatedRequest(to endpoint: String, server: Server, completion: @escaping (String?) -> Void) {
        guard let cookie = pveAuthCookie else {
            completion("Kein Auth-Cookie vorhanden. Bitte zuerst einloggen.")
            return
        }
        
        let fullURL = "https://\(server.address):8006/api2/json\(endpoint)"
        
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["curl", "-s", "-k", "--connect-timeout", "5", "-X", "GET", fullURL,
                             "-H", "Cookie: PVEAuthCookie=\(cookie)"]
        process.standardOutput = pipe
        
        do {
            try process.run()
        } catch {
            completion("Fehler beim Request: \(error.localizedDescription)")
            return
        }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let response = String(data: data, encoding: .utf8)
        completion(response)
    }
}
