//
//  ServerConfigurationPane.swift
//  Mocknoa
//
//  Created by Wilma Rodriguez on 2/16/22.
//

import SwiftUI

/// Lists the currently selected server's endpoints
struct ServerConfigurationPane: View {
    @Binding var currentServer: Server
    @Binding var selectedEndpoint: Endpoint?
    @State var showNewRow = false

    var body: some View {
        VStack {
            List {
                ForEach(currentServer.endpoints, id:\.self) { endpoint in
                    EndpointRow(selectedEndpoint: $selectedEndpoint, endpoint: endpoint)
                }
                if showNewRow {
                    NewEndpointRow(showNewRow: $showNewRow, currentServer: $currentServer, selectedEndpoint: $selectedEndpoint)
                }
            } //: LIST
            BottomToolBar(showNewRow: $showNewRow)
        } //: VSTACK
    }
}

/// Add new Endpoint button row
struct NewEndpointRow: View {
    @State private var path: String = ""
    @Binding var showNewRow: Bool
    @Binding var currentServer: Server
    @Binding var selectedEndpoint: Endpoint?

    var body: some View {
        HStack {
            TextField("", text: $path)
                .background(Color.gray)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .cornerRadius(3)
            Spacer()
            Button {
                // Create new endpoint
                let endpoint = Endpoint(path: path, action: .get, statusCode: 0000, jsonString: "SomeJSON")
                currentServer.endpoints.append(endpoint)
                selectedEndpoint = endpoint
                showNewRow.toggle()
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

struct EndpointRow: View {
    @Binding internal var selectedEndpoint: Endpoint?
    internal let endpoint: Endpoint

    var body: some View {
        HStack {
            Text(endpoint.path)
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
            if selectedEndpoint != endpoint {
                selectedEndpoint = endpoint
            }
        }
    }
}
