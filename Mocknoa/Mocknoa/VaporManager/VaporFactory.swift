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

    public static func generateServer(server: Server, completion: @escaping (Application?, DispatchQueue, Error?) -> Void) {
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
                try configure(app: app, server: server)
                completion(app, serverQueue, nil)
                try app.run()
            } catch {
                completion(nil, serverQueue, error)
            }
        }
    }

    public static func configure( app: Application, server: Server) throws {
        app.http.server.configuration.port = Int(server.port)
        try routes(app: app, server: server)
    }

    public static func routes(app: Application, server: Server) throws {
        generateRoutes(app: app, server: server)
    }

    private static func generateRoutes(app: Application, server: Server) {
        let getEndpoints = server.endpoints.getEndpoints
        let postEndpoints = server.endpoints.postEndpoints
        let patchEndpoints = server.endpoints.patchEndpoints
        let deleteEndpoints = server.endpoints.deleteEndpoints

        generateGetRoutes(app: app, server: server, endPoints: getEndpoints)
        generatePostRoutes(app: app, server: server, endPoints: postEndpoints)
        generatePatchRoutes(app: app, server: server, endPoints: patchEndpoints)
        generateDeleteRoutes(app: app, server: server, endPoints: deleteEndpoints)
        print("Routes")
        print(app.routes)
    }

    private static func generateGetRoutes(app: Application, server: Server, endPoints: [Endpoint]) {
        endPoints.forEach { endpoint in
            app.get(endpoint.pathComponents) { _ in
                return Response(status: .custom(code: endpoint.statusCode, reasonPhrase: ""), body: .init(string: endpoint.jsonString))
            }
        }
    }

    private static func generatePostRoutes(app: Application, server: Server, endPoints: [Endpoint]) {
        endPoints.forEach { endpoint in
            app.post(endpoint.pathComponents) { _ in
                return Response(status: .custom(code: endpoint.statusCode, reasonPhrase: ""), body: .init(string: endpoint.jsonString))
            }
        }
    }

    private static func generatePatchRoutes(app: Application, server: Server, endPoints: [Endpoint]) {
        endPoints.forEach { endpoint in
            app.patch(endpoint.pathComponents) { _ in
                return Response(status: .custom(code: endpoint.statusCode, reasonPhrase: ""), body: .init(string: endpoint.jsonString))
            }
        }
    }

    private static func generateDeleteRoutes(app: Application, server: Server, endPoints: [Endpoint]) {
        endPoints.forEach { endpoint in
            app.delete(endpoint.pathComponents) { _ in
                return Response(status: .custom(code: endpoint.statusCode, reasonPhrase: ""), body: .init(string: endpoint.jsonString))
            }
        }
    }

}
