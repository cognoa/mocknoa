//
//  ServerConfigurationPane.swift
//  Mocknoa
//
//  Created by Wilma Rodriguez on 2/16/22.
//

import SwiftUI

/// Lists the currently selected server's endpoints
struct ServerConfigurationPane: View {
    @StateObject internal var globalStateManager: GlobalStateManager
    @Binding var currentServer: Server?
    @Binding var selectedEndpoint: Endpoint?
    @State var showNewRow = false

    var body: some View {
        if let currentServer = currentServer, let server = globalStateManager.getServerById(id: currentServer.id) {
            VStack {
                List {
                    ForEach(server.sortedEndpoints, id:\.self) { endpoint in
                        EndpointRow(selectedEndpoint: $selectedEndpoint, endpoint: endpoint)
                    }
                    if showNewRow {
                        NewEndpointRow(
                            globalStateManager: globalStateManager,
                            showNewRow: $showNewRow,
                            currentServer: $currentServer,
                            selectedEndpoint: $selectedEndpoint)
                    }
                } //: LIST
                BottomToolBar(showNewRow: $showNewRow)
            }
        }

    }
}

/// Add new Endpoint button row
struct NewEndpointRow: View {
    @StateObject internal var globalStateManager: GlobalStateManager
    @State private var path: String = ""
    @Binding var showNewRow: Bool
    @Binding var currentServer: Server?
    @Binding var selectedEndpoint: Endpoint?

    var body: some View {
        if var currentServer = currentServer {
            HStack {
                TextField("", text: $path)
                    .background(Color.gray)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .cornerRadius(3)
                Spacer()
                Button {
                    // Create new endpoint                    
                    guard let endpoint = globalStateManager.createEndpointOnServerWithDefaultSettings(server: currentServer, path: path) else {
                        showNewRow.toggle()
                        return
                    }
                    selectedEndpoint = endpoint
                    showNewRow.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct EndpointRow: View {
    @Binding internal var selectedEndpoint: Endpoint?
    @State internal var endpoint: Endpoint

    var body: some View {
        HStack {
            Text("\(endpoint.action.displayString)")
                .fontWeight(.bold)
                .foregroundColor(endpoint.action.displayColor)
                .frame(width: 55, height: 22, alignment: .leading)
            Text("\(endpoint.path)")
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 1)
            // Change the background color if this is the current option
                .background {
                    if selectedEndpoint == endpoint { Color.gray }
                }
                .cornerRadius(4)
            Spacer()
        }
        // Switch to selected endpoint
        .onTapGesture {
            selectedEndpoint = endpoint
        }.onChange(of: selectedEndpoint) { newValue in
            if let newValue = newValue, newValue.id == endpoint.id {
                self.endpoint = newValue
            }
        }
    }
}
