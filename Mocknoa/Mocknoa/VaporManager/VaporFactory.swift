//
//  VaporFactory.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/15/22.
//

import Foundation
import Vapor

public class VaporFactory {
    public static func generateServer(server: Server, completion: @escaping (Application?, DispatchQueue, Error?) -> Void) {
        let serverQueue = DispatchQueue(label: server.id, attributes: .concurrent)
        serverQueue.async {
            do {
                var env = try Environment.detect()
                try LoggingSystem.bootstrap(from: &env)
                let app = Application(env)
                defer { app.shutdown() }
                try configure(app: app, server: server)
                try app.run()
                completion(app, serverQueue, nil)
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
        app.get { req in
            return "Hello Jonathan"
        }

        app.get("hello") { req -> String in
            return "Hello, world"
        }

        app.get("test") { req -> String in
            return "test"
        }
    }
}
