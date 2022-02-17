//
//  ContentView.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/7/22.
//

import SwiftUI


struct ContentView: View {
    @StateObject internal var globalStateManager: GlobalStateManager
    @State var currentServer: Server?
    @State var selectedEndpoint: Endpoint?

    var body: some View {
        NavigationView {
            // List of Servers
            SidebarView(globalStateManager: globalStateManager, currentServer: $currentServer, selectedEndpoint: $selectedEndpoint)
            // List of currentServer's endpoints
            ServerConfigurationPane(
                globalStateManager: globalStateManager,
                currentServer: $currentServer,
                selectedEndpoint: $selectedEndpoint)
            // Endpoint configuration View
            EndpointDetailView(globalStateManager: globalStateManager, endpoint: $selectedEndpoint, currentServer: $currentServer)
        }
        .frame(minWidth: 600, idealWidth: 800, maxWidth: .infinity, minHeight: 400, idealHeight: 600, maxHeight: .infinity)
        .onAppear {
            currentServer = globalStateManager.globalEnvironment.sortedServers.first
        }
    }
}
/// List of current Servers
struct SidebarView: View {
    @StateObject internal var globalStateManager: GlobalStateManager
    @State private var isDefaultItemActive = true
    @State private var showingAlert        = false
    @State private var showNewServerRow    = false
    @Binding internal var currentServer: Server?
    @Binding internal var selectedEndpoint: Endpoint?

    var body: some View {
        VStack {
            List {
                ForEach(globalStateManager.globalEnvironment.sortedServers, id: \.self) { server in
                    ServerRow(
                        globalStateManager: globalStateManager,
                        currentServer: $currentServer,
                        selectedEndpoint: $selectedEndpoint,
                        server: server)
                }
                if showNewServerRow {
                    NewServerRow(
                        globalStateManager: globalStateManager,
                        showNewServerRow: $showNewServerRow)
                }
                Spacer()
            } //: LIST
            .listStyle(SidebarListStyle())
            // Bottom add server button row
            BottomToolBar(showNewRow: $showNewServerRow)
        }
    }
}

/// Add new server button row
struct NewServerRow: View {
    @StateObject internal var globalStateManager: GlobalStateManager
    @State private var name: String = ""
    @Binding var showNewServerRow: Bool
//    @Binding var servers: [Server]


    var body: some View {
        HStack {
            TextField("", text: $name)
                .background(Color.gray)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .cornerRadius(3)
            Spacer()
            Button {
                // Create new server
                globalStateManager.createAndAddNewServerConfiguration(name: name)
                showNewServerRow.toggle()
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

struct ServerRow: View {
    @StateObject internal var globalStateManager: GlobalStateManager
    @Binding var currentServer: Server?
    @Binding var selectedEndpoint: Endpoint?
    @State private var isSelected = false
    @State private var presentDeleteButton = false
    var server: Server

    // TODO - REMOVE
//    private func getDummyEndpoints() -> [Endpoint] {
//        [.init(path: "somePath1", action: .get, statusCode: 555, jsonString: "JSON string"),
//         .init(path: "somePath2", action: .post, statusCode: 555, jsonString: "JSON string"),
//         .init(path: "somePath3", action: .delete, statusCode: 555, jsonString: "JSON string")]
//    }

    var body: some View {
        VStack {
            HStack {
                Text(server.name)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 1)
                Spacer()
                if presentDeleteButton {
                    Button {
                        // Delete server
                        globalStateManager.deleteServerConfiguration(server: server)
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
            PlayToolBar()
            Divider()
        } //: VSTACK
        // Select a server
        .onTapGesture {
            if currentServer != server {
                currentServer = server
                selectedEndpoint = nil
                isSelected = true
            }
//            if var currentServer = currentServer,
//               let currentServerEndpoints = globalStateManager.globalEnvironment.servers[currentServer.id]?.endpoints {
//                currentServer.endpoints = currentServerEndpoints
//            }
        }

    // Change the background color if this is the current option
        .background {
            if currentServer == server { Color.gray }
        }
        .cornerRadius(4)
        .padding(.all, 2)
    }
}

struct PlayToolBar: View {
    var body: some View {
        HStack {
            Button {
                print("Start Server")
            } label: {
                Image(systemName: "play.fill")
            } // Start Button
            .clipShape(Circle())
            .aspectRatio(contentMode: .fit)

            Button {
                print("Stop Server")
            } label: {
                Image(systemName: "stop.fill")
            } // Stop Button
            .clipShape(Circle())
            .aspectRatio(contentMode: .fit)
        } //: HSTACK
    }
}
