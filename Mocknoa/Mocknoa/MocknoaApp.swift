//
//  MocknoaApp.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/7/22.
//

import SwiftUI
import Vapor

@main
struct MocknoaApp: App {
    var globalStateManager = GlobalStateManager()

    init() {
//        let serverConfig = Server(name: "Test Server 1", port: 9000, endpoints: [])
//        self.globalStateManager.addServerConfiguration(server: serverConfig)
//        self.globalStateManager.startServer(server: serverConfig)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(globalStateManager: globalStateManager)
        }
    }
}
