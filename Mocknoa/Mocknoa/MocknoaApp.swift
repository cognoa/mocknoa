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
    var serverApp: Application?

    init() {
        self.serverApp = try? VaporFactory.generateServer()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
