//
//  ContentView.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/7/22.
//

import SwiftUI


struct ContentView: View {
    @State var currentServer = Server(name: "Server 331", port: 0331, endpoints: [])
    @State var selectedEndpoint: Endpoint?

    let servers: [Server] = [
        .init(name: "Server 331", port: 0331, endpoints: []),
        .init(name: "Server 332", port: 0332, endpoints: []),
        .init(name: "Server 333", port: 0333, endpoints: []),
        .init(name: "Server 334", port: 0334, endpoints: []),
    ]

    var body: some View {
        NavigationView {
            // List of Servers
            SidebarView(currentServer: $currentServer, selectedEndpoint: $selectedEndpoint, servers: servers)
            // List of currentServer's endpoints
            ServerConfigurationPane(currentServer: $currentServer, selectedEndpoint: $selectedEndpoint)
            // Endpoint configuration View
            EndpointDetailView(endpoint: $selectedEndpoint)
        }
        // Allows the mac app window to be resizable,
        // while it won't shrink smaller than the min size set here
        .frame(width: 600, height: 400)
    }
}

/// List of current Servers
struct SidebarView: View {
    @State private var isDefaultItemActive = true
    @Binding var currentServer: Server
    @Binding var selectedEndpoint: Endpoint?
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
                // Select a server
                .onTapGesture {
                    if currentServer != server {
                        currentServer = server
                        selectedEndpoint = nil
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
