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

    var body: some View {
        ForEach(currentServer.endpoints, id:\.self) { endpoint in
                HStack {
                    Text(endpoint.path)
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
            // Switch to selected endpoint
            .onTapGesture {
                if selectedEndpoint != endpoint {
                    selectedEndpoint = endpoint
                }
            }
        }
        Spacer()
    }
}
