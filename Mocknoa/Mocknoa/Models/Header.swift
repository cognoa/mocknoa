//
//  Header.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/21/22.
//

import Foundation

public struct Header: Codable, Hashable {
    public var id: String = UUID().uuidString
    public var name: String
    public var value: String
}
