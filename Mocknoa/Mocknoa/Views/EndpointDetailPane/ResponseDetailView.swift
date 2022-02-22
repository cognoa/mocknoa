//
//  ResponseDetailView.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/21/22.
//

import Foundation
import SwiftUI


struct ResponseDetailView: View {
    @EnvironmentObject internal var globalStateManager: GlobalStateManager
    @Binding var currentServer: Server?
    @Binding internal var endpoint: Endpoint?
    @Binding internal var selectedResponse: MockResponse?
    @State private var statusCode: String = ""

    var body: some View {
        if let currentServer = currentServer, let localResponse = selectedResponse {

            HStack {
                Text("Status Code: ")
                    .padding(.leading, EndpointDetailView.leadingPadding)
                TextField("New Status Code", text: $statusCode)
                    .background(Color.gray)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .cornerRadius(3)
                    .onChange(of: statusCode, perform: { newValue in
                        if let statusCode = UInt(statusCode), let indexOfResponse = endpoint?.indexOf(response: localResponse) {
                            self.endpoint?.responses[indexOfResponse].statusCode = statusCode
                            self.updateEndpoint()
                        }
                    })
                    .padding(.leading, EndpointDetailView.leadingPadding)
            }

            TabView {
                VStack {
                    JSONInputTextEditor(
                        server: currentServer,
                        endpoint: $endpoint,
                        selectedResponse: $selectedResponse,   
                        jsonText: selectedResponse?.jsonString ?? ""
                    ).padding(.horizontal, 10)
                        .padding(.bottom, 10)
                }.tabItem {
                    Text("JSON Body")
                }

                VStack {
                    Text("Header View")
                }.tabItem {
                    Text("Headers")
                }
            }.padding(.horizontal, 10)
        }
    }

    private func updateEndpoint() {
        guard let endpoint = endpoint, let currentServer = currentServer else {
            return
        }
        globalStateManager.updateEndpointOnServer(server: currentServer, endpoint: endpoint)
    }
}

struct JSONInputTextEditor: View {
    @EnvironmentObject internal var globalStateManager: GlobalStateManager
    internal var server: Server
    @Binding internal var endpoint: Endpoint?
    @Binding internal var selectedResponse: MockResponse?
    @State internal var jsonText: String

    var body: some View {
        VStack {
            TextEditor(text: $jsonText)
        }.onChange(of: jsonText) { newValue in
            if let localResponse = selectedResponse,
               var localEndpoint = endpoint,
               let indexOfResponse = localEndpoint.indexOf(response: localResponse)
            {
                localEndpoint.responses[indexOfResponse].jsonString = newValue
                endpoint?.responses[indexOfResponse].jsonString = newValue
                globalStateManager.updateEndpointOnServer(server: server, endpoint: localEndpoint)
            }
        }.onAppear {
            jsonText = selectedResponse?.jsonString ?? ""
        }
    }
}
