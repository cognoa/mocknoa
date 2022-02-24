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
    @State private var selectedTab = "json"
    var body: some View {
        if let currentServer = currentServer, let localEndpoint = endpoint, let localResponse = selectedResponse {
            Group() {
                HStack {
                    Text("Status Code: ")
                        .padding(.leading, EndpointDetailView.leadingPadding)
                    TextField("New Status Code", text: $statusCode)
                        .background(Color.gray)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .cornerRadius(3)
                        .padding(.leading, EndpointDetailView.leadingPadding)
                        .onChange(of: statusCode, perform: { newValue in
                            if let statusCode = UInt(statusCode), let indexOfResponse = endpoint?.indexOf(response: localResponse) {
                                self.endpoint?.responses[indexOfResponse].statusCode = statusCode
                                self.updateEndpoint()
                            }
                        })
                        .onAppear {
                            if let selectedResponse = selectedResponse {
                                statusCode = String(selectedResponse.statusCode)
                            }
                        }
                }

                TabView(selection: $selectedTab) {
                    VStack {
                        JSONInputTextEditor(
                            server: currentServer,
                            endpoint: $endpoint,
                            selectedResponse: $selectedResponse,
                            jsonText: selectedResponse?.jsonString ?? ""
                        ).padding(.horizontal, 10)
                            .padding(.bottom, 10)
                    }.tabItem {
                        Text("Response Body")
                    }
                    .tag("json")

                    VStack {
                        Text("Header View")
                    }.tabItem {
                        Text("Response Headers")
                    }
                    .tag("headers")
                }
                .padding(.horizontal, 10)
                .onChange(of: endpoint) { newValue in
                    if newValue != localEndpoint {
                        selectedTab = "json"
                    }
                }
            }
            .onChange(of: selectedResponse) { newValue in
                if let newValue = newValue {
                    statusCode = String(newValue.statusCode)
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

struct JSONInputTextEditor: View {
    @EnvironmentObject internal var globalStateManager: GlobalStateManager
    internal var server: Server
    @Binding internal var endpoint: Endpoint?
    @Binding internal var selectedResponse: MockResponse?
    @State internal var jsonText: String

    var body: some View {        
        VStack {
            TextEditor(text: $jsonText)
                .onChange(of: jsonText) { newValue in
                    if let localResponse = selectedResponse,
                       var localEndpoint = endpoint,
                       let indexOfResponse = localEndpoint.indexOf(response: localResponse)
                    {
                        localEndpoint.responses[indexOfResponse].jsonString = newValue
//                        endpoint?.responses[indexOfResponse].jsonString = newValue
                        globalStateManager.updateEndpointOnServer(server: server, endpoint: localEndpoint)
                    }
                }
        }
        .onAppear {
            if let selectedResponse = selectedResponse {
                jsonText = selectedResponse.jsonString
            }
        }
        .onChange(of: selectedResponse) { newValue in
            if let newValue = newValue {
                jsonText = newValue.jsonString
            }
        }
    }
}

struct ResponseHeadersDetailView: View {
    @EnvironmentObject internal var globalStateManager: GlobalStateManager
    internal var server: Server
    @Binding internal var endpoint: Endpoint?
    @Binding internal var selectedResponse: MockResponse?
    @State internal var headers: [Header]
    @State internal var currentHeader: Header?

    var body: some View {
        if let selectedResponse = selectedResponse {
            List(selectedResponse.headers, id: \.self, selection: $currentHeader) { header in

            }
        }
    }
}

struct HeadersListRow: View {
    @EnvironmentObject internal var globalStateManager: GlobalStateManager
    internal var server: Server
    @Binding internal var endpoint: Endpoint?
    @Binding internal var selectedResponse: MockResponse?

    var body: some View {
        VStack {

        }
    }
}
