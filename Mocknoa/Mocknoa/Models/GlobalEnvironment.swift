//
//  GlobalEnvironment.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/15/22.
//

import Foundation
import Vapor

public class GlobalEnvironment: Codable {
    public var serverConfigurations: [String: Server] = [:]    
}
