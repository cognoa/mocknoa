//
//  Endpoint.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/15/22.
//

import Foundation

public struct Endpoint: Codable, Hashable {
    public var id: String = UUID().uuidString
    public var path: String
    public var action: HttpAction
    public var statusCode: UInt
    public var jsonString: String
    public var creationDate = Date()

    public func defaultEndpoint() -> Endpoint {
        return Endpoint(path: "", action: .get, statusCode: 200, jsonString: "")
    }
}

extension Array where Element == Endpoint {
    public var sortedEndpointsByCreation: [Endpoint] {
        return self.sorted {
            return $0.creationDate < $1.creationDate
        }
    }
}
