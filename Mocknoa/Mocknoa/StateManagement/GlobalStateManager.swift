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
    @Published public var endpointNextResponseIndex: [String : Int] = [:]
    @Published public var activeVaporServers: [String: Application] = [:]
    private var serverDispatchQueues: [String: DispatchQueue] = [:]



    public init() {
        self.globalEnvironment = GlobalEnvironment()
        self.globalSelectionStatus = GlobalSelectionStatus()
    }

    public func setCurrentServer(server: Server) {
        globalSelectionStatus.currentServer = server
    }

    public func setName(server: Server, name: String) {        
        globalEnvironment.servers[server.id]?.name = name
        self.objectWillChange.send()
        saveGlobalEnvironment()
    }

    public func setPort(server: Server, port: UInt) {
        globalEnvironment.servers[server.id]?.port = port
        self.objectWillChange.send()
        saveGlobalEnvironment()
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
        self.objectWillChange.send()
        saveGlobalEnvironment()
    }

    public func createEndpointOnServerWithDefaultSettings(server: Server, path: String) -> Endpoint? {
        let endpoint = Endpoint(path: path, action: .get, responses: MockResponse.defaultResponseArray)
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

    public func serverContaining(endpoint: Endpoint) -> Server? {
        for server in Array(globalEnvironment.servers.values) {
            if !server.endpoints.filter({ $0.id == endpoint.id }).isEmpty {
                return server
            }
        }
        return nil
    }
}

// MARK: Endpoint Response Maangement
extension GlobalStateManager {
    public func createNewResponseOn(endpoint: Endpoint) {
        guard let localServer = serverContaining(endpoint: endpoint),
              let newResponse = MockResponse.defaultResponseArray.first
        else {
            print("Unable to create new response")
            // Add error handling
            return
        }
        globalEnvironment.servers[localServer.id]?.endpointsDictionary[endpoint.id]?.responses.append(newResponse)
        self.objectWillChange.send()
        saveGlobalEnvironment()
    }

    public func deleteResponseFromEndpoint(endpoint: Endpoint, response: MockResponse) {
        guard let localServer = serverContaining(endpoint: endpoint),
              let localEndpoint = getEndpointBy(id: endpoint.id, server: localServer),
              localEndpoint.responses.count > 1
        else {
            // Add Error Handling
            return
        }
        let newResponseArray = localEndpoint.responses.filter({ $0.id != response.id })
        globalEnvironment.servers[localServer.id]?.endpointsDictionary[endpoint.id]?.responses = newResponseArray
    }

    fileprivate func resetEndpointResponseIndexesFor(server: Server) {
        for endpoint in server.endpoints {
            endpointNextResponseIndex[endpoint.id] = 0
        }
    }

    private func nextResponseIndexFor(endpoint: Endpoint) -> Int? {
        return endpointNextResponseIndex[endpoint.id]
    }

    public func nextMockResponseForEndpoint(_ endpoint: Endpoint) -> MockResponse? {
        guard !endpoint.responses.isEmpty, let nextIndex = nextResponseIndexFor(endpoint: endpoint) else { return nil }

        if endpoint.responseSequenceMode == .random {
            return endpoint.responses.randomElement()
        }

        if endpoint.responses.count == 1 && endpoint.responseSequenceMode == .loopResponses {
            return endpoint.responses[0]
        } else {
            if nextIndex == endpoint.responses.count - 1 {
                if endpoint.responseSequenceMode == .loopResponses {
                    endpointNextResponseIndex[endpoint.id] = 0
                } else {
                    endpointNextResponseIndex[endpoint.id] = nextIndex + 1
                }
                return endpoint.responses[nextIndex]
            } else if nextIndex >= endpoint.responses.count && endpoint.responseSequenceMode == .return404AfterLast {
                return MockResponse.endOfResponses404
            } else {
                endpointNextResponseIndex[endpoint.id] = nextIndex + 1
                return endpoint.responses[nextIndex]
            }
        }
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

        VaporFactory.generateServer(globalStateManager: self, server: server) { app, queue, error in
            if let error = error {
                print("Error generating server \(error)")
            } else if let app = app {
                DispatchQueue.main.async {
                    self.activeVaporServers[server.id] = app
                    self.serverDispatchQueues[server.id] = queue
                    self.resetEndpointResponseIndexesFor(server: server)
                    self.objectWillChange.send()
                }
            }
        }

        MocknoaFileManager.saveGlobalEnvironment(globalEnvironment)
    }

    public func stopServer(server: Server) {
        guard
            let activeServer = activeVaporServers[server.id],
            let serverQueue = serverDispatchQueues[server.id]
        else {
            // There is no server with the specified ID running so return
            return
        }

        serverQueue.async {
            activeServer.shutdown()
        }
        activeVaporServers.removeValue(forKey: server.id)
        resetEndpointResponseIndexesFor(server: server)
        self.objectWillChange.send()
    }

    public func serverIsActive(server: Server) -> Bool {
        return activeVaporServers[server.id] != nil
    }
}


extension GlobalStateManager {
    public enum Error {
        case serverAlreadyRunningError

    }
}
