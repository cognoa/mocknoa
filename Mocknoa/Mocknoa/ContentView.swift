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

    /// Should not be less than set min width and height in the `panelFrame()` modifier
    let smallPanelMinWidth: CGFloat   = 200
    let smallPanelIdealWidth: CGFloat = 220
    let largePanelMultiplier: CGFloat = 150
    var largePanelMinWidth: CGFloat { return smallPanelMinWidth + largePanelMultiplier }
    var largePanelIdealWidth: CGFloat { return smallPanelIdealWidth + largePanelMultiplier }

    var body: some View {
        NavigationView {
            // List of Servers
            SidebarView(globalStateManager: globalStateManager, currentServer: $currentServer, selectedEndpoint: $selectedEndpoint)
                .panelFrame(minWidth: smallPanelMinWidth, idealWidth: smallPanelIdealWidth)

            // List of currentServer's endpoints
            ServerConfigurationPane(globalStateManager: globalStateManager,
                                    currentServer: $currentServer,
                                    selectedEndpoint: $selectedEndpoint)
                .panelFrame(minWidth: smallPanelMinWidth, idealWidth: smallPanelIdealWidth)

            // Endpoint configuration View
            EndpointDetailView(globalStateManager: globalStateManager, endpoint: $selectedEndpoint, currentServer: $currentServer)
                .panelFrame(minWidth: largePanelMinWidth, idealWidth: largePanelIdealWidth)

        }
        .panelFrame()
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
            List(globalStateManager.globalEnvironment.sortedServers, id: \.self, selection: $currentServer) { server in
                    ServerRow(
                        globalStateManager: globalStateManager,
                        currentServer: $currentServer,
                        selectedEndpoint: $selectedEndpoint,
                        server: server
                    )
                    .listRowBackground(self.currentServer?.id == server.id ? Color.gray : Color.clear)
                    .onTapGesture {
                        if let currentServerLocal = self.currentServer, currentServerLocal.id != server.id {
                            currentServer = server
                            selectedEndpoint = nil
                        }
                    }
            } //: LIST
            .listStyle(SidebarListStyle())
            .onChange(of: currentServer) { newValue in
                print("Current Server: \(currentServer?.name)")
            }
            Spacer()
            if showNewServerRow {
                NewServerRow(
                    globalStateManager: globalStateManager,
                    showNewServerRow: $showNewServerRow)
            }

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
        .padding(.horizontal, 8)
    }
}

struct ServerRow: View {
    @StateObject internal var globalStateManager: GlobalStateManager
    @Binding var currentServer: Server?
    @Binding var selectedEndpoint: Endpoint?
    var server: Server

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text(server.name)
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: "macpro.gen2.fill")
                        .foregroundColor(globalStateManager.activeVaporServers[server.id] != nil ? .green : .red)
                        .font(.system(size: 17))
//                        .frame(width: 20, height: 30, alignment: .center)
                        .padding(.horizontal, 2)
                        .padding(.bottom, 2)
                } //: HSTACK


                HStack {
                    Text("Port: ")
                        .font(.body)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(String(server.port))
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 2)
                } //: ELSE
            } //: VSTACK
            .padding(.horizontal, 4)
            ServerToolBar(globalStateManager: globalStateManager, server: server)
                .padding(.top, 4)
//            Divider()
        } //: VSTACK
        .cornerRadius(4)
    }
}

struct ServerToolBar: View {
    @ObservedObject internal var globalStateManager: GlobalStateManager
    var server: Server
    let minSize: CGFloat = 10
    @State private var showAlert = false

    var body: some View {
        HStack {
            // Start Button
            Button {
                print("Start Server")
                globalStateManager.startServer(server: server)
            } label: {
                Image(systemName: "play.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: minSize, minHeight: minSize)
            }
            .clipShape(Circle())
            .aspectRatio(contentMode: .fit)

            // Stop Button
            Button {
                globalStateManager.stopServer(server: server)
            } label: {
                Image(systemName: "stop.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: minSize, minHeight: minSize)
            }
            .clipShape(Circle())
            .aspectRatio(contentMode: .fit)

            Spacer()

            // Delete server
            Button {
                showAlert = true
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .font(Font.title.weight(.bold))
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: minSize, minHeight: minSize)
                    .foregroundColor(.red)
            } // Delete Button
            .clipShape(Circle())
            .aspectRatio(contentMode: .fit)
            .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Confirm Delete"),
                        message: Text("Are you sure you want to delete this server? This action cannot be undone."),
                        primaryButton: .default(
                            Text("Cancel"),
                            action: {

                            }
                        ),
                        secondaryButton: .destructive(
                            Text("Delete"),
                            action: {
                                self.globalStateManager.stopServer(server: server)
                                self.globalStateManager.deleteServerConfiguration(server: server)
                            }
                        )
                    )
                }
        } //: HSTACK
        .padding(.bottom, 4)
    }
}
