//
//  Endpoint.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/15/22.
//

import Foundation
import Vapor

public struct Endpoint: Codable, Hashable {
    public enum ResponseSequenceMode: String, Codable, CaseIterable, Identifiable {
        case loopResponses
        case random
        case return404AfterLast

        public var id: Self { self }

        public var displayString: String {
            switch self {
            case .loopResponses: return "Loop Responses"
            case .random: return "Random"
            case .return404AfterLast: return "Return 404 Error After Last"
            }
        }
    }

    public var id: String = UUID().uuidString
    public var path: String
    public var action: HttpAction
    public var creationDate = Date()
    public var responses: [MockResponse]
    public var responseSequenceMode: ResponseSequenceMode = .loopResponses
    public var rankIndex: Int = 0

    public func defaultEndpoint() -> Endpoint {
        return Endpoint(path: "/", action: .get, responses: MockResponse.defaultResponseArray)
    }

    public func trimmedPath() -> String {
        guard let firstCharacter = path.first else { return path }
        var localPath = String(path)
        if firstCharacter == "/" {
           localPath.removeFirst()
            return localPath
        } else {
            return path
        }
    }

    public var pathArray: [String] {
        let pathElements = trimmedPath().components(separatedBy: "/")
        return pathElements
    }

    public var pathComponents: [PathComponent] {
        let pathArray = self.pathArray
        return pathArray.map({ component in
            return PathComponent(stringLiteral: component)
        })
    }

    public func indexOf(response: MockResponse) -> Int? {
        for (index, tempResponse) in responses.enumerated() {
            if tempResponse.id == response.id {
                return index
            }
        }
        return nil
    }
}

extension Array where Element == Endpoint {
    public var sortedEndpointsByCreation: [Endpoint] {
        return self.sorted {
            return $0.creationDate < $1.creationDate
        }
    }

    public var getEndpoints: [Endpoint] { return self.filter({ $0.action == .get }) }
    public var postEndpoints: [Endpoint] { return self.filter({ $0.action == .post }) }
    public var patchEndpoints: [Endpoint] { return self.filter({ $0.action == .patch }) }
    public var deleteEndpoints: [Endpoint] { return self.filter({ $0.action == .delete }) }
}
