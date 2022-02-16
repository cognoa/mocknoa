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

    // TODO - UPDATE
    @State var servers: [Server] = [
        .init(name: "Server 331", port: 0331, endpoints: []),
        .init(name: "Server 332", port: 0332, endpoints: []),
        .init(name: "Server 333", port: 0333, endpoints: []),
        .init(name: "Server 334", port: 0334, endpoints: []),
    ]

    var body: some View {
        NavigationView {
            // List of Servers
            SidebarView(currentServer: $currentServer, selectedEndpoint: $selectedEndpoint, servers: $servers)
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
    @State private var showingAlert        = false
    @State private var showNewServerRow    = false
    @Binding internal var currentServer: Server
    @Binding internal var selectedEndpoint: Endpoint?
    @Binding internal var servers: [Server]

    var body: some View {
        VStack {
            List {
                ForEach(servers, id: \.self) { server in
                    ServerRow(currentServer: $currentServer,
                              servers: $servers,
                              selectedEndpoint: $selectedEndpoint,
                              server: server)
                }
                if showNewServerRow {
                    NewServerRow(showNewServerRow: $showNewServerRow, servers: $servers)
                }
                Spacer()
            } //: LIST
            .listStyle(SidebarListStyle()) // Gives you this sweet sidebar look
            // Bottom add server button row
            HStack(alignment: .center) {
                Button {
                    showNewServerRow.toggle()
                } label: {
                    Image(systemName: "plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.white)
                        .padding(.all, 2)
                }
                .aspectRatio(contentMode: .fit)
                .padding(.vertical, 1)
                .padding(.horizontal, 2)
                Spacer()
            } //: HSTACK
        }
    }
}

/// Add new server button row
struct NewServerRow: View {
    @State private var name: String = ""
    @Binding var showNewServerRow: Bool
    @Binding var servers: [Server]


    var body: some View {
        HStack {
            TextField("", text: $name)
                .background { Color.gray }
                .cornerRadius(3)
            Spacer()
            Button {
                // Create new server
                servers.append(.init(name: name, port: 0000, endpoints: []))
                showNewServerRow.toggle()
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

struct ServerRow: View {
    @Binding var currentServer: Server
    @Binding var servers: [Server]
    @Binding var selectedEndpoint: Endpoint?
    @State private var isSelected = false
    @State private var presentDeleteButton = false
    var server: Server

    // TODO - REMOVE
    private func getDummyEndpoints() -> [Endpoint] {
        [.init(path: "somePath1", action: .get, statusCode: 555, jsonString: "JSON string"),
         .init(path: "somePath2", action: .post, statusCode: 555, jsonString: "JSON string"),
         .init(path: "somePath3", action: .delete, statusCode: 555, jsonString: "JSON string")]
    }

    var body: some View {
        HStack {
            Text(server.name)
                .padding(.horizontal, 8)
                .padding(.vertical, 1)
            // Change the background color if this is the current option
                .background {
                    if currentServer == server { Color.gray }
                }
                .cornerRadius(4)
            Spacer()
            if presentDeleteButton {
                Button {
                    // Delete server
                    servers = servers.filter({ $0 != server })
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                                        .clipShape(Circle())
                }
            }
        } //: HSTACK
        // Display delete button when hovering over server row
        .onHover { isHovering in
            presentDeleteButton = isHovering
        }
        // Select a server
        .onTapGesture {
            if currentServer != server {
                currentServer = server
                selectedEndpoint = nil
                isSelected = true
            }
            if currentServer == servers[1] {
                currentServer.endpoints = getDummyEndpoints()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
