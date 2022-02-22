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
            SidebarView(currentServer: $currentServer, selectedEndpoint: $selectedEndpoint)
                .panelFrame(minWidth: smallPanelMinWidth, idealWidth: smallPanelIdealWidth)
                .environmentObject(globalStateManager)

            // List of currentServer's endpoints
            ServerConfigurationPane(currentServer: $currentServer,
                                    selectedEndpoint: $selectedEndpoint)
                .panelFrame(minWidth: smallPanelMinWidth, idealWidth: largePanelMinWidth)
                .environmentObject(globalStateManager
                )
            // Endpoint configuration View
            EndpointDetailView(endpoint: $selectedEndpoint, currentServer: $currentServer)
                .panelFrame(minWidth: largePanelIdealWidth, idealWidth: largePanelIdealWidth + smallPanelMinWidth)
                .environmentObject(globalStateManager)
        }
        .panelFrame()
        .onAppear {
            currentServer = globalStateManager.globalEnvironment.sortedServers.first
        }
    }
}    

/// List of current Servers
struct SidebarView: View {
    @EnvironmentObject  internal var globalStateManager: GlobalStateManager
    @State private var isDefaultItemActive = true
    @State private var showingAlert        = false
    @State private var showNewServerRow    = false
    @Binding internal var currentServer: Server?
    @Binding internal var selectedEndpoint: Endpoint?

    var body: some View {
        VStack {
            List(globalStateManager.globalEnvironment.sortedServers, id: \.self, selection: $currentServer) { server in
                    ServerRow(
                        currentServer: $currentServer,
                        selectedEndpoint: $selectedEndpoint,
                        server: server
                    )
            }
            .listStyle(SidebarListStyle())
            .onChange(of: currentServer) { newValue in
                if let newValue = newValue {
                    print(newValue.name)
                    currentServer = newValue
                    selectedEndpoint = newValue.sortedEndpoints.first
                }
            }
            Spacer()
            if showNewServerRow {
                NewServerRow(
                    showNewServerRow: $showNewServerRow)
                    .padding(.horizontal, 4)
            }

            // Bottom add server button row
            BottomToolBar(showNewRow: $showNewServerRow)
        }
    }
}

/// Add new server button row
struct NewServerRow: View {
    private enum Field: Int, Hashable {
        case name
    }

    @EnvironmentObject internal var globalStateManager: GlobalStateManager
    @State private var name: String = ""
    @Binding var showNewServerRow: Bool
    @FocusState private var focusedField: Field?

    var body: some View {
        HStack {
            TextField("", text: $name)
                .background(Color.gray)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .cornerRadius(3)
                .onSubmit {
                    createNewServer()
                }
                .focused($focusedField, equals: .name)
                .onExitCommand {
                    showNewServerRow.toggle()
                }
            Spacer()
            Button {
                createNewServer()
            } label: {
                Image(systemName: "plus")
            }
        }
        .padding(.horizontal, 8)
        .onAppear {
            print("New Server Row Appeared")
            focusedField = .name
        }
    }

    private func createNewServer() {
        guard !name.isEmpty else { return }
        globalStateManager.createAndAddNewServerConfiguration(name: name)
        showNewServerRow.toggle()
    }
}

struct ServerRow: View {
    @EnvironmentObject  internal var globalStateManager: GlobalStateManager
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
                        .foregroundColor(globalStateManager.activeVaporServers[server.id] != nil ? .green : .gray)
                        .font(.system(size: 17))
                } //: HSTACK


                HStack {
                    Text("Port: \(String(server.port))")
                        .font(.body)
                        .fontWeight(.semibold)
                    Spacer()
                } //: ELSE
            } //: VSTACK
            .padding(.horizontal, 4)
            ServerToolBar(server: server)
                .padding(.top, 4)
//            Divider()
        } //: VSTACK
        .cornerRadius(4)
    }
}

struct ServerToolBar: View {
    @EnvironmentObject internal var globalStateManager: GlobalStateManager
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
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .foregroundColor(.green)
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: minSize, minHeight: minSize)
            }
            .aspectRatio(contentMode: .fit)

            // Stop Button
            Button {
                globalStateManager.stopServer(server: server)
            } label: {
                Image(systemName: "stop.circle.fill")
                    .resizable()
                    .foregroundColor(.red)
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: minSize, minHeight: minSize)
            }
            .aspectRatio(contentMode: .fit)

            Spacer()

            // Delete server
            Button {
                showAlert = true
            } label: {
                Image(systemName: "minus.circle")
                    .resizable()
                    .foregroundColor(.red)
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: minSize, minHeight: minSize)
            } // Delete Button
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
