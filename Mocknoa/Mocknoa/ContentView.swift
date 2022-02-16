//
//  ContentView.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/7/22.
//

import SwiftUI


struct ContentView: View {
    @State var currentServer = Server(name: "Server 331", port: 0331, endpoints: [])

    let servers: [Server] = [
        .init(name: "Server 331", port: 0331, endpoints: []),
        .init(name: "Server 332", port: 0332, endpoints: []),
        .init(name: "Server 333", port: 0333, endpoints: []),
        .init(name: "Server 334", port: 0334, endpoints: []),
    ]

    var body: some View {
        NavigationView {
            // List of Servers
            SidebarView(currentServer: $currentServer, servers: servers)
            // List of currentServer's endpoints
            ServerConfigurationPane(currentServer: $currentServer)
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

    private func getDummyEndpoints() -> [Endpoint] {
        [.init(path: "somePath1", action: .get, statusCode: 555, jsonString: "JSON string"),
         .init(path: "somePath2", action: .post, statusCode: 555, jsonString: "JSON string"),
         .init(path: "somePath3", action: .delete, statusCode: 555, jsonString: "JSON string")]
    }

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
                    if currentServer == servers[1] {
                        currentServer.endpoints = getDummyEndpoints()
                    }
                }
            }
            .listStyle(SidebarListStyle()) // Gives you this sweet sidebar look
            Spacer()
        }
    }
}

/// Lists the currently selected server's endpoints
struct ServerConfigurationPane: View {
    @Binding var currentServer: Server

    /*
     public struct Endpoint: Codable, Hashable {
     public var path: String
     public var action: HttpAction
     public var statusCode: UInt
     public var jsonString: String
     }
     */

    var body: some View {
        ForEach(currentServer.endpoints, id:\.self) { endpoint in
            VStack {
                HStack {
                    Text(endpoint.path)
                    Spacer()
                }
                HttpActionPicker(httpAction: endpoint.action)
            }
            .padding()
        }
        Spacer()
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
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
