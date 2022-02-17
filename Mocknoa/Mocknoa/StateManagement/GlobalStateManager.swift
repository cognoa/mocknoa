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
    private var serverDispatchQueues: [String: DispatchQueue] = [:]

    public init() {
        self.globalEnvironment = GlobalEnvironment()
    }

    public func addServerConfiguration(server: Server) {
        globalEnvironment.serverConfigurations[server.id] = server
    }

    public func deleteServerConfiguration(server: Server) {
        globalEnvironment.serverConfigurations[server.id] = nil
    }

    public func startServer(server: Server) {
        guard activeVaporServers[server.id] == nil else  {
            // Server is already running
            return
        }

        VaporFactory.generateServer(server: server) { app, queue, error in
            if let error = error {
                print("Error generating server \(error)")
            } else if let app = app {
                self.activeVaporServers[server.id] = app
                self.serverDispatchQueues[server.id] = queue
            }
        }

        MocknoaFileManager.saveGlobalEnvironment(globalEnvironment)
    }

    public func stopServer(server: Server) {
        guard let activeServer = activeVaporServers[server.id] else {
            // There is no server with the specified ID running so return
            return
        }
        activeServer.shutdown()
    }

    private func saveGlobalEnvironment() {

    }
}
