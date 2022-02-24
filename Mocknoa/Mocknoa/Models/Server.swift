//
//  Server.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/15/22.
//

import Foundation

public struct Server: Codable, Hashable, Identifiable {
    public var id = UUID().uuidString
    public var creationDate = Date()
    public var name: String
    public var port: UInt
    public var endpointsDictionary: [String: Endpoint] = defaultEndpoints

    public var endpoints: [Endpoint] {
        return Array(endpointsDictionary.values)
    }

    public var sortedEndpoints: [Endpoint] {
        return Array(endpointsDictionary.values).sortedEndpointsByCreation
    }

    public static var defaultEndpoints: [String: Endpoint] {
        let endpoint = Endpoint(path: "/", action: .get, responses: MockResponse.defaultResponseArray)
        return [endpoint.id: endpoint]
    }

    public static func defaultServer() -> Server {
        return Server(name: "New Server", port: 8080, endpointsDictionary: defaultEndpoints)
    }

    public static func indexOfServerInArrayOfServers(server: Server, servers: [Server]) -> Int {
        for (index, localServer) in servers.enumerated() {
            if server.id == localServer.id { return index }
        }
        return 0
    }

    public func addEndpoint(_ endpoint: Endpoint) {

    }
}

extension Array where Element == Server {
    public var sortedByCreationDate: [Server] {
        sorted { $0.creationDate < $1.creationDate }
    }
}
