//
//  ContentView.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/7/22.
//

import SwiftUI


struct ContentView: View {
    var body: some View {
        NavigationView {
            SidebarView()
            ServerConfigurationPane()
            JSONInputTextEditor()
        }        
    }
}

struct SidebarView: View {
    @State private var isDefaultItemActive = true

    var body: some View {
        List {
            Text("Server 1")
            // ...
        }.listStyle(SidebarListStyle()) // Gives you this sweet sidebar look
    }
}


struct ServerConfigurationPane: View {
    var body: some View {
        HttpActionPicker()
    }
}

struct HttpActionPicker: View {
    @State var httpAction: HttpAction = .get
    var body: some View {
        Picker("Http Action", selection: $httpAction) {
            ForEach(HttpAction.allCases) { action in
                Text(action.rawValue.capitalized)
            }
        }
    }
}

struct JSONInputTextEditor: View {
    @State var text: String = "Test JSON"
    var body: some View {
        Text("Input JSON Below")
        TextEditor(text: $text)
    }
}
