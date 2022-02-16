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

    var body: some View {
        ForEach(currentServer.endpoints, id:\.self) { endpoint in
            VStack {
                HStack {
                    Text(endpoint.path)
                    Spacer()
                }
                HttpActionPicker(httpAction: endpoint.action)
            }
            .padding()
        }
        Spacer()
    }
}

struct HttpActionPicker: View {
    @State var httpAction: HttpAction = .get

    var body: some View {
        Picker("Http Action", selection: $httpAction) {
            ForEach(HttpAction.allCases) { action in
                Text(action.rawValue.capitalized)
            }
        }
    }
}
