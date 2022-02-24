//
//  Pasteboard+Utilities.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/23/22.
//

import Foundation
import AppKit

public enum PasteboardUtilities {
    static func addTextToPasteboard(text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(text, forType: .string)
    }

    static func addEndpointFullHttpPathToPasteboard(server: Server, endPoint: Endpoint) {
        let fullPath = generateFullHttpPathStringFrom(server: server, endpoint: endPoint)
        addTextToPasteboard(text: fullPath)
    }

    static func generateFullHttpPathStringFrom(server: Server, endpoint: Endpoint) -> String {
        return Constants.EnvironmentConstants.localHostString + ":\(String(server.port))/" + endpoint.trimmedPath()
    }
}
