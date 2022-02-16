//
//  VaporFactory.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/15/22.
//

import Foundation
import Vapor

public class VaporFactory {

    public static func generateServer(server: Server, completion: (Application?, Error?) -> Void) {
        DispatchQueue.global().async {
            guard var env = try? Environment.detect() else { return }
            try? LoggingSystem.bootstrap(from: &env)
            let app = Application(env)
            defer { app.shutdown() }
            try? configure(app: app)
            try? app.run()
//            return app
        }
    }

    public static func configure( app: Application) throws {
//        app.middleware.use
        try routes(app)
    }

    public static func routes(_ app: Application) throws {
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
