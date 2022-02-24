//
//  VaporFactory.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/15/22.
//

import Foundation
import Vapor
import SwiftUI

public class VaporFactory {
    public static var dispatchQueues: [String: DispatchQueue] = [:]
    public static var loggingInstantiated: Bool = false
    public static func generateServer(globalStateManager: GlobalStateManager, server: Server, completion: @escaping (Application?, DispatchQueue, Error?) -> Void) {
        let serverQueue = DispatchQueue(label: server.id, attributes: .concurrent)
        dispatchQueues[server.id] = serverQueue
        serverQueue.async {
            do {
                var env = try Environment.detect()
                if !loggingInstantiated {
                    try LoggingSystem.bootstrap(from: &env)
                }
                loggingInstantiated = true
                let app = Application(env)
                try configure(globalStateManager: globalStateManager, app: app, server: server)
                completion(app, serverQueue, nil)
                try app.run()
            } catch {
                completion(nil, serverQueue, error)
            }
        }
    }

    public static func configure(globalStateManager: GlobalStateManager, app: Application, server: Server) throws {
        app.http.server.configuration.port = Int(server.port)
        try routes(globalStateManager: globalStateManager, app: app, server: server)
    }

    public static func routes(globalStateManager: GlobalStateManager, app: Application, server: Server) throws {
        generateRoutes(globalStateManager: globalStateManager, app: app, server: server)
    }

    private static func generateRoutes(globalStateManager: GlobalStateManager, app: Application, server: Server) {
        let getEndpoints = server.endpoints.getEndpoints
        let postEndpoints = server.endpoints.postEndpoints
        let patchEndpoints = server.endpoints.patchEndpoints
        let deleteEndpoints = server.endpoints.deleteEndpoints

        generateGetRoutes(globalStateManager: globalStateManager, app: app, server: server, endPoints: getEndpoints)
        generatePostRoutes(globalStateManager: globalStateManager, app: app, server: server, endPoints: postEndpoints)
        generatePatchRoutes(globalStateManager: globalStateManager, app: app, server: server, endPoints: patchEndpoints)
        generateDeleteRoutes(globalStateManager: globalStateManager, app: app, server: server, endPoints: deleteEndpoints)
        print("Routes")
        print(app.routes)
    }

    private static func generateGetRoutes(globalStateManager: GlobalStateManager, app: Application, server: Server, endPoints: [Endpoint]) {
        endPoints.forEach { endpoint in
            app.get(endpoint.pathComponents)  { req in
                return generateNextResponseFor(globalStateManager: globalStateManager, server: server, endpoint: endpoint)
            }
        }
    }

    private static func generatePostRoutes(globalStateManager: GlobalStateManager, app: Application, server: Server, endPoints: [Endpoint]) {
        endPoints.forEach { endpoint in
            app.post(endpoint.pathComponents) { _ in
                return generateNextResponseFor(globalStateManager: globalStateManager, server: server, endpoint: endpoint)
            }
        }
    }

    private static func generatePatchRoutes(globalStateManager: GlobalStateManager, app: Application, server: Server, endPoints: [Endpoint]) {
        endPoints.forEach { endpoint in
            app.patch(endpoint.pathComponents) { _ in
                return generateNextResponseFor(globalStateManager: globalStateManager, server: server, endpoint: endpoint)
            }
        }
    }

    private static func generateDeleteRoutes(globalStateManager: GlobalStateManager, app: Application, server: Server, endPoints: [Endpoint]) {
        endPoints.forEach { endpoint in
            app.delete(endpoint.pathComponents) { _ in
                return generateNextResponseFor(globalStateManager: globalStateManager, server: server, endpoint: endpoint)
            }
        }
    }

    private static func responseNotFound(endPoint: Endpoint) -> Response {
        Response(status: .notFound, body: .init(string: "No response found for requested resource at route \(endPoint.path)"))
    }

    private static func generateNextResponseFor(globalStateManager: GlobalStateManager, server: Server, endpoint: Endpoint) -> Response {
        var response = responseNotFound(endPoint: endpoint)
        if let nextMockResponse = globalStateManager.nextMockResponseForEndpoint(endpoint) {
            response = Response(status: .custom(code: nextMockResponse.statusCode, reasonPhrase: ""), body: .init(string: nextMockResponse.jsonString))
        }
        return response
    }
}
