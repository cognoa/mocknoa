//
//  EndpointDetailView.swift
//  Mocknoa
//
//  Created by Wilma Rodriguez on 2/16/22.
//

import SwiftUI

struct EndpointDetailView: View {
    @StateObject internal var globalStateManager: GlobalStateManager
    @Binding internal var endpoint: Endpoint?
    @Binding internal var currentServer: Server?
    @State private var path: String = ""
    @State private var statusCode: String = ""

    var body: some View {
        if let endpoint = endpoint, let currentServer = currentServer {
            VStack {
                HStack {
                    Text("Path: ")
                        .padding(.horizontal, 2)

                    TextField("New path", text: $path)
                        .background(Color.gray)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .cornerRadius(3)
                        .onSubmit {
                            print("Endpoint Path Textfield Submitted")
                            self.endpoint?.path = path
                            updateEndpoint()
                        }
                }
                HStack {
                    Text("Status Code: ")
                        .padding()
                    TextField("New Status Code", text: $statusCode)
                        .background(Color.gray)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .cornerRadius(3)
                        .onSubmit {
                            if let statusCode = UInt(statusCode) {
                                self.endpoint?.statusCode = statusCode
                                updateEndpoint()
                            }
                        }
                }
                HttpActionPicker(httpAction: endpoint.action)
                JSONInputTextEditor()
            }
            .padding()
        } else {
            Text("")
                .padding()
        }
    }

    private func updateEndpoint() {
        guard let endpoint = endpoint, let currentServer = currentServer else {
            return
        }
        globalStateManager.updateEndpointOnServer(server: currentServer, endpoint: endpoint)
    }
}

struct HttpActionPicker: View {
    @State var httpAction: HttpAction = .get

    var body: some View {
        Picker("Http Action", selection: $httpAction) {
            ForEach(HttpAction.allCases) { action in
                Text(action.rawValue.capitalized)
            }
        }.onChange(of: httpAction, perform: { action in
            print("Picker submitted \(httpAction.rawValue)")
        })
    }
}

struct JSONInputTextEditor: View {
    @State var text: String = "Test JSON"

    var body: some View {
        VStack {
            Text("Input JSON Below")
            TextEditor(text: $text)
        }
    }
}
