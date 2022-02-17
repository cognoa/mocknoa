//
//  GlobalStateManager.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/16/22.
//

import Foundation
import Vapor
import Combine

public class GlobalSelectionStatus: Codable {
    public var currentServer: Server?
    public var selectedEndpoint: Endpoint?
}

public class GlobalStateManager: ObservableObject {
    @Published public var globalEnvironment: GlobalEnvironment
    @Published public var globalSelectionStatus: GlobalSelectionStatus

    public func setCurrentServer(server: Server) {
        globalSelectionStatus.currentServer = server
    }

    public func setSelectedEndpoint(endpoint: Endpoint) {
        globalSelectionStatus.selectedEndpoint = endpoint
    }

    public var activeVaporServers: [String: Application] = [:]
    private var serverDispatchQueues: [String: DispatchQueue] = [:]

    public init() {
        self.globalEnvironment = GlobalEnvironment()
        self.globalSelectionStatus = GlobalSelectionStatus()
    }

    public func addServerConfiguration(server: Server) {
        globalEnvironment.servers[server.id] = server
    }

    public func createAndAddNewServerConfiguration(name: String) {
        let newServer = Server(name: name, port: 8080)
        globalEnvironment.servers[newServer.id] = newServer
    }

    public func deleteServerConfiguration(server: Server) {
        globalEnvironment.servers[server.id] = nil
    }

    public func getServerById(id: String) -> Server? {
        if let server = globalEnvironment.servers[id] {
            return server
        } else {
            return nil
        }
    }
}

//MARK: Endpoint Management
extension GlobalStateManager {
    public func updateEndpointOnServer(server: Server, endpoint: Endpoint) {
        globalEnvironment.servers[server.id]?.endpointsDictionary[endpoint.id] = endpoint
    }

    public func createEndpointOnServerWithDefaultSettings(server: Server, path: String) -> Endpoint? {
        let endpoint = Endpoint(path: path, action: .get, statusCode: 200, jsonString: "")
        guard globalEnvironment.servers[server.id] != nil else {
            return nil
        }
        globalEnvironment.servers[server.id]?.endpointsDictionary[endpoint.id] = endpoint
        return endpoint
    }
}

// MARK: Vapor Server Management
extension GlobalStateManager {
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
}


extension GlobalStateManager {
    public enum Error {
        case serverAlreadyRunningError

    }
}
