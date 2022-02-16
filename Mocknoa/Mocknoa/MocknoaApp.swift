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
    var serverApp = try? VaporFactory.generateServer()
//    var serverApp2 = try? VaporFactory.generateServer()
    init() {

    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
