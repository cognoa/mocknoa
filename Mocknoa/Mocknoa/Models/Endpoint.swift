//
//  Endpoint.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/15/22.
//

import Foundation

public struct Endpoint: Codable, Hashable {
    public var path: String
    public var action: HttpAction
    public var statusCode: UInt
    public var jsonString: String
}
