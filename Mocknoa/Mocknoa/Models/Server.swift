//
//  Server.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/15/22.
//

import Foundation

public struct Server: Codable, Hashable {
    public var id = UUID().uuidString
    public var creationDate = Date()
    public var name: String
    public var port: UInt
    public var endpointsDictionary: [String: Endpoint] = defaultEndpoints

    public var sortedEndpoints: [Endpoint] {
        return Array(endpointsDictionary.values).sortedEndpointsByCreation
    }

    public static var defaultEndpoints: [String: Endpoint] {
        let endpoint = Endpoint(path: "", action: .get, statusCode: 200, jsonString: "Default")
        return [endpoint.id: endpoint]
    }

    public static func defaultServer() -> Server {
        return Server(name: "New Server", port: 8080, endpointsDictionary: defaultEndpoints)
    }
}

extension Array where Element == Server {
    public var sortedByCreationDate: [Server] {
        sorted { $0.creationDate < $1.creationDate }
    }
}
