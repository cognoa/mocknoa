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
    @Published public var activeVaporServers: [String: Application] = [:]
    private var serverDispatchQueues: [String: DispatchQueue] = [:]

    public func setCurrentServer(server: Server) {
        globalSelectionStatus.currentServer = server
    }

    public func setPort(server: Server, port: UInt) {
        globalEnvironment.servers[server.id]?.port = port
        self.objectWillChange.send()
        saveGlobalEnvironment()
    }

    public func setSelectedEndpoint(endpoint: Endpoint) {
        globalSelectionStatus.selectedEndpoint = endpoint
    }

    public init() {
        self.globalEnvironment = GlobalEnvironment()
        self.globalSelectionStatus = GlobalSelectionStatus()
    }

    public func addServerConfiguration(server: Server) {
        globalEnvironment.servers[server.id] = server
        saveGlobalEnvironment()
    }

    public func createAndAddNewServerConfiguration(name: String) {
        let newServer = Server(name: name, port: 8080)
        globalEnvironment.servers[newServer.id] = newServer
        saveGlobalEnvironment()
    }

    public func deleteServerConfiguration(server: Server) {
        globalEnvironment.servers.removeValue(forKey: server.id)
        self.objectWillChange.send()
        saveGlobalEnvironment()
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
        saveGlobalEnvironment()
    }

    public func createEndpointOnServerWithDefaultSettings(server: Server, path: String) -> Endpoint? {
        let endpoint = Endpoint(path: path, action: .get, statusCode: 200, jsonString: "")
        guard globalEnvironment.servers[server.id] != nil else {
            return nil
        }
        globalEnvironment.servers[server.id]?.endpointsDictionary[endpoint.id] = endpoint
        saveGlobalEnvironment()
        return endpoint
    }

    public func getEndpointBy(id: String, server: Server) -> Endpoint? {
        guard let server = getServerById(id: server.id) else { return nil }
        return server.endpointsDictionary[id]
    }
}

// MARK: Persistence and LifeCycle
extension GlobalStateManager {
    public func appIsIniting() {
        if let globalEnvironment = MocknoaFileManager.retrieveGlobalEnvironment() {
            self.globalEnvironment = globalEnvironment
        }
    }

    internal func saveGlobalEnvironment() {
        MocknoaFileManager.saveGlobalEnvironment(globalEnvironment)
    }
}

// MARK: Vapor Server Management
extension GlobalStateManager {
    public func startServer(server: Server) {
        guard activeVaporServers[server.id] == nil else  {
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
        activeVaporServers.removeValue(forKey: server.id)
    }
}


extension GlobalStateManager {
    public enum Error {
        case serverAlreadyRunningError

    }
}
