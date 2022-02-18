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
        globalStateManager.appIsIniting()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(globalStateManager: globalStateManager)
                .preferredColorScheme(.dark)
        }
    }
}
