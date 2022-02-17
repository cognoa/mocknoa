//
//  Server.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/15/22.
//

import Foundation

public struct Server: Codable, Hashable {
    public var id = UUID().uuidString
    public var name: String
    public var port: UInt
    public var endpoints: [Endpoint] = [Self.defaultEndpoint]

    public static var defaultEndpoint: Endpoint {
        Endpoint(path: "", action: .get, statusCode: 200, jsonString: "Default")
    }
}
