//
//  ContentView.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/7/22.
//

import SwiftUI


struct ContentView: View {
    @State var currentServer = Server(name: "Server 331", port: 0331)

    let servers: [Server] = [
        .init(name: "Server 331", port: 0331),
        .init(name: "Server 332", port: 0332),
        .init(name: "Server 333", port: 0333),
        .init(name: "Server 334", port: 0334),
    ]

    var body: some View {
        NavigationView {
            SidebarView(currentServer: $currentServer, servers: servers)
            ServerConfigurationPane()
            JSONInputTextEditor()
        }
        // Allows the mac app window to be resizable,
        // while it won't shrink smaller than the min size set here
        .frame(width: 600, height: 400)
    }
}

struct SidebarView: View {
    @State private var isDefaultItemActive = true
    @Binding var currentServer: Server
    let servers: [Server]

    var body: some View {
        VStack {
            ForEach(servers, id: \.self) { server in
                HStack {
                    Text(server.name)
                    // Change the background color if this is the current option
                        .foregroundColor(currentServer == server ? Color.blue : Color.white)
                    Spacer()
                }
                .padding(8)
                .onTapGesture {
                    if currentServer != server {
                        currentServer = server
                    }
                }
            }
            .listStyle(SidebarListStyle()) // Gives you this sweet sidebar look
            Spacer()
        }
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
