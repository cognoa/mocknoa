//
//  GlobalStateManager.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/16/22.
//

import Foundation
import Vapor
import Combine

public class GlobalStateManager {
    @Published public var globalEnvironment: GlobalEnvironment

    public var activeVaporServers: [String: Application] = [:]

    public init() {
        self.globalEnvironment = GlobalEnvironment()
    }

    public func addServer(server: Server) {
//        globalEnvironment.servers
    }

    public func startServer(server: Server) {
        guard activeVaporServers[server.id] == nil else  {
            // Server is already running
            return
        }

    }

    public func stopServer(server: Server) {
        guard let activeServer = activeVaporServers[server.id] else {
            // There is no server with the specified ID running so return
            return
        }
        activeServer.shutdown()
    }
}
