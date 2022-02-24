//
//  ServerConfigurationPane.swift
//  Mocknoa
//
//  Created by Wilma Rodriguez on 2/16/22.
//

import SwiftUI

/// Lists the currently selected server's endpoints
struct ServerConfigurationPane: View {
    @EnvironmentObject internal var globalStateManager: GlobalStateManager
    @Binding var currentServer: Server?
    @Binding var selectedEndpoint: Endpoint?
    @State var showNewRow = false
    @State var serverName: String = ""
    @State var serverPort: String = ""
    var body: some View {
        if let currentServer = currentServer, let server = globalStateManager.getServerById(id: currentServer.id) {
            VStack {
                GroupBox {
                    VStack(alignment: .leading) {
                        Text("Server Name")
                            .fontWeight(.bold)
                        TextField("", text: $serverName)
                            .cornerRadius(5)
                            .onChange(of: serverName) { newValue in
                                self.globalStateManager.setName(server: currentServer, name: serverName)
                            }

                        Text("Server Port")
                            .fontWeight(.bold)
                        TextField("", text: $serverPort)
                            .cornerRadius(5)
                            .onChange(of: serverPort) { newValue in
                                guard let portNumber = UInt(serverPort) else { return }
                                self.globalStateManager.setPort(server: currentServer, port: UInt(portNumber))
                            }
                    }
                }
                .padding(.horizontal, 10)

                List(currentServer.endpoints, id: \.self, selection: $selectedEndpoint) { endpoint in
                    EndpointRow(selectedEndpoint: $selectedEndpoint, endpoint: endpoint)
                        .onTapGesture {
                            selectedEndpoint = endpoint
                        }
                }
                .listStyle(.plain)
                .onDeleteCommand {
                    print("Delete")
                }


                if showNewRow {
                    NewEndpointRow(
                        showNewRow: $showNewRow,
                        currentServer: $currentServer,
                        selectedEndpoint: $selectedEndpoint)
                        .padding(.horizontal, 8)
                }

                BottomToolBar(showNewRow: $showNewRow)
            }.onAppear {
                serverName = currentServer.name
                serverPort = String(currentServer.port)
            }.onChange(of: self.currentServer) { newValue in
                guard let localCurrentServer = newValue else { return }
                serverName = localCurrentServer.name
                serverPort = String(localCurrentServer.port)
            }
        }
    }
}

struct EndpointRow: View {
    @Binding internal var selectedEndpoint: Endpoint?
    @State internal var endpoint: Endpoint
    @State private var isTargeted = true

    var body: some View {
        HStack {
            Text("\(endpoint.action.displayString)")
                .fontWeight(.bold)
                .foregroundColor(endpoint.action.displayColor)
                .frame(width: 55, height: 22, alignment: .leading)
            Spacer()
            Text("\(endpoint.path)")
                .fontWeight(.semibold)
                .frame(alignment: .trailing)
                .padding(.vertical, 1)
                .cornerRadius(4)
        }
        .padding(.horizontal, 3)
        .cornerRadius(4)
        // Needed to make the entire VStack tappable for `onTapGesture` to work
        .contentShape(Rectangle())
        // Switch to selected endpoint
        .onChange(of: selectedEndpoint) { newValue in
            if let newValue = newValue, newValue.id == endpoint.id {
                self.endpoint = newValue
            }
        }.onDrag {
            print("Did Drag")
            var item = NSItemProvider(object: NSString(string: endpoint.id))
            item.suggestedName = endpoint.id
            return item
        }
        .onDrop(of: ["public.utf8-plain-text"], isTargeted: $isTargeted) { provider in
            print("Did drop")
            print(provider.first)
            guard let endpointSwapping = provider.first, let id = endpointSwapping.suggestedName else {
                return false
            }
            print("Swapping ID: \(id)")
            print("Current Endpoint ID: \(self.endpoint.id)")
            return false
        }

    }
}

/// Add new Endpoint button row
struct NewEndpointRow: View {
    private enum Field: Int, Hashable {
        case name
    }

    @EnvironmentObject internal var globalStateManager: GlobalStateManager
    @State private var path: String = ""
    @Binding var showNewRow: Bool
    @Binding var currentServer: Server?
    @Binding var selectedEndpoint: Endpoint?
    @FocusState private var focusedField: Field?
    
    var body: some View {
        if let currentServer = currentServer {
            HStack {
                TextField("", text: $path)
                    .background(Color.gray)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .cornerRadius(3)
                    .onSubmit {
                        createEndpointOnServer(server: currentServer)
                    }
                    .focused($focusedField, equals: .name)
                    .onExitCommand {
                        showNewRow.toggle()
                    }
                Spacer()
                Button {
                    self.createEndpointOnServer(server: currentServer)
                } label: {
                    Image(systemName: "plus")
                }
            }
            .padding(.horizontal, 8)
            .onAppear {
                focusedField = .name
            }
        }
    }

    private func createEndpointOnServer(server: Server) {
        // Create new endpoint
        guard let endpoint = globalStateManager
                .createEndpointOnServerWithDefaultSettings(server: server, path: path)
        else {
            // Handle errors
            return
        }
        selectedEndpoint = endpoint
        showNewRow.toggle()
    }
}
