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
    @State var httpAction: HttpAction?
    @State private var path: String = ""
    @State private var statusCode: String = ""
    @State private var jsonText: String = ""
    private let leadingPadding: CGFloat = 10
    var body: some View {
        if let endpoint = endpoint, let currentServer = currentServer {
            VStack (alignment: .leading) {
                Text("Path: ")
                    .padding(.leading, leadingPadding)
                TextField("New path", text: $path)
                    .background(Color.gray)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .cornerRadius(3)
                    .onSubmit {
                        print("Endpoint Path Textfield Submitted")
                        self.endpoint?.path = path
                        updateEndpoint()
                    }
                    .padding(.leading, leadingPadding)

                Text("Status Code: ")
                    .padding(.leading, leadingPadding)
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
                    .padding(.leading, leadingPadding)


                if let httpAction = httpAction {
                    HttpActionPicker(globalStateManager: globalStateManager, server: currentServer, endpoint: $endpoint, httpAction: $httpAction, localHttpAction: httpAction)
                }
                Divider()
                    .padding(.top, 10)
                JSONInputTextEditor(
                    globalStateManager: globalStateManager,
                    server: currentServer,
                    endpoint: $endpoint,
                    jsonText: $jsonText
                ).padding(.horizontal, 10)
                    .padding(.bottom, 10)
            }
            .padding(.top, 10)
            .padding(.trailing, 10)
            .onAppear {
                print("Endpoint detail did appear")
                if let globalEndpoint = globalStateManager.getEndpointBy(id: endpoint.id, server: currentServer) {
                    path = globalEndpoint.path
                    statusCode = String(globalEndpoint.statusCode)
                    httpAction = globalEndpoint.action
                    jsonText = globalEndpoint.jsonString
                }
            }.onChange(of: endpoint) { endpoint in
                if let globalEndpoint = globalStateManager.getEndpointBy(id: endpoint.id, server: currentServer) {
                    path = globalEndpoint.path
                    statusCode = String(globalEndpoint.statusCode)
                    httpAction = globalEndpoint.action
                    jsonText = globalEndpoint.jsonString
                }
            }
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
    @StateObject internal var globalStateManager: GlobalStateManager
    internal var server: Server
    @Binding internal var endpoint: Endpoint?
    @Binding internal var httpAction: HttpAction?
    @State internal var localHttpAction: HttpAction

    var body: some View {
        Text("HTTP Action:")
            .padding(.leading, 10)
        Picker("", selection: $localHttpAction) {
            ForEach(HttpAction.allCases) { action in
                Text(action.rawValue.capitalized)
            }
        }.onChange(of: localHttpAction, perform: { action in
            if var localEndpoint = endpoint {
                localHttpAction = action
                httpAction = action
                endpoint?.action = action
                localEndpoint.action = action
                globalStateManager.updateEndpointOnServer(server: server, endpoint: localEndpoint)
            }
        })
        .onAppear {
            if let httpAction = httpAction {
                localHttpAction = httpAction
            }
        }
    }
}

struct JSONInputTextEditor: View {
    @StateObject internal var globalStateManager: GlobalStateManager
    internal var server: Server
    @Binding internal var endpoint: Endpoint?
    @Binding internal var jsonText: String

    var body: some View {
        VStack {
            Text("Input JSON Below")
            TextEditor(text: $jsonText)
        }.onChange(of: jsonText) { jsonText in
            if var localEndpoint = endpoint {
                localEndpoint.jsonString = jsonText
                endpoint?.jsonString = jsonText
                globalStateManager.updateEndpointOnServer(server: server, endpoint: localEndpoint)
            }
        }
    }
}
