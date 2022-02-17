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
    var server: Server
    @State private var portText = ""

    private var port: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        let number = NSNumber(value: server.port)
        if let formattedValue = formatter.string(from: number) {
            return formattedValue
        } else {
            return "0000"
        }
    }

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text(server.name)
                        .font(.headline)
                        .padding(.vertical, 1)
                    Spacer()
                } //: HSTACK

                if currentServer != server {
                    HStack {
                        Text("Port: ")
                            .font(.footnote)
                        TextField("Add port number", text: $portText)
                            .multilineTextAlignment(.trailing)
                            .font(.footnote)
                            .cornerRadius(4)
                            .padding(.horizontal, 2)
                            .onSubmit {
                                if let portNumber = UInt(portText) {
                                    globalStateManager.setPort(for: currentServer,
                                                                  with: portNumber)
                                }
                            }
                    } //: HSTACK
                } else {
                    HStack {
                        Text("Port: ")
                            .font(.footnote)
                        Spacer()
                        Text("\(port)")
                            .font(.footnote)
                    } //: HSTACK
                } //: ELSE
            } //: VSTACK
            .padding(.horizontal, 8)
            ServerToolBar(globalStateManager: globalStateManager, server: server)
                .padding(.all, 4)
            Divider()
        } //: VSTACK
        // Needed to make the entire VStack tappable for `onTapGesture` to work
        .contentShape(Rectangle())
        // Select Server
        .onTapGesture {
            if currentServer != server {
                portText = port
                currentServer = server
                selectedEndpoint = nil
            }
        }
        // Change the background color if this is the current option
        .background {
            if currentServer == server { Color.gray }
        }
        .cornerRadius(4)
        .onAppear {
            portText = port
        }
    }
}

struct ServerToolBar: View {
    @ObservedObject internal var globalStateManager: GlobalStateManager
    var server: Server
    let minSize: CGFloat = 7

    var body: some View {
        HStack {
            Button {
                print("Start Server")
            } label: {
                Image(systemName: "play.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: minSize, minHeight: minSize)
            } // Start Button
            .clipShape(Circle())
            .aspectRatio(contentMode: .fit)

            Button {
                print("Stop Server")
            } label: {
                Image(systemName: "stop.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: minSize, minHeight: minSize)
            } // Stop Button
            .clipShape(Circle())
            .aspectRatio(contentMode: .fit)

            Spacer()

            Button {
                // Delete server
                globalStateManager.deleteServerConfiguration(server: server)
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
        } //: HSTACK
    }
}
