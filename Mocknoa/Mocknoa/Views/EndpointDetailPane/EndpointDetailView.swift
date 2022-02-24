//
//  EndpointDetailView.swift
//  Mocknoa
//
//  Created by Wilma Rodriguez on 2/16/22.
//

import SwiftUI

struct EndpointDetailView: View {
    @EnvironmentObject internal var globalStateManager: GlobalStateManager
    @Binding internal var endpoint: Endpoint?
    @Binding internal var currentServer: Server?
    @State internal var httpAction: HttpAction?
    @State internal var sequenceMode: Endpoint.ResponseSequenceMode?
    @State private var path: String = ""
    @State var selectedResponse: MockResponse?

    static let leadingPadding: CGFloat = 10

    var body: some View {
        if let endpoint = endpoint, let currentServer = currentServer {
            VStack (alignment: .leading) {
                GroupBox {
                    VStack (alignment: .leading) {
                        HStack{
                            Text("Path: ")
                                .padding(.leading, Self.leadingPadding)
                            Spacer()
                            Button {
                                PasteboardUtilities.addEndpointFullHttpPathToPasteboard(server: currentServer, endPoint: endpoint)
                            } label: {
                                Text("Copy to Clipboard")
                            }

                        }
                        TextField("New path", text: $path)
                            .background(Color.gray)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .cornerRadius(3)
                            .onChange(of: path, perform: { newValue in
                                print("Endpoint Path Textfield Submitted")
                                self.endpoint?.path = path
                                updateEndpoint()
                            })
                            .padding(.leading, Self.leadingPadding)

                        if let httpAction = httpAction {
                            HttpActionPicker(
                                server: currentServer,
                                endpoint: $endpoint,
                                httpAction: $httpAction,
                                localHttpAction: httpAction)
                        }

                        if let sequenceMode = sequenceMode {
                            ResponseSequenceModePicker(
                                server: currentServer,
                                endpoint: $endpoint,
                                sequenceMode: $sequenceMode,
                                localSequenceMode: sequenceMode)
                        }
                    }
                }
                Divider()
                    .padding(.top, 10)

                ResponseTabView(server: currentServer, endpoint: $endpoint, selectedResponse: $selectedResponse)
                ResponseDetailView(currentServer: $currentServer, endpoint: $endpoint, selectedResponse: $selectedResponse)
            }
            .padding(.top, 10)
            .padding(.trailing, 10)
            .onAppear {
                if let globalEndpoint = globalStateManager.getEndpointBy(id: endpoint.id, server: currentServer) {
                    path = globalEndpoint.path
                    httpAction = globalEndpoint.action
                    selectedResponse = globalEndpoint.responses.first
                    sequenceMode = globalEndpoint.responseSequenceMode
                }
            }.onChange(of: endpoint) { endpoint in
                if let globalEndpoint = globalStateManager.getEndpointBy(id: endpoint.id, server: currentServer) {
                    path = globalEndpoint.path
                    httpAction = globalEndpoint.action
                    sequenceMode = globalEndpoint.responseSequenceMode
                    selectedResponse = globalEndpoint.responses.first
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
    @EnvironmentObject internal var globalStateManager: GlobalStateManager
    internal var server: Server
    @Binding internal var endpoint: Endpoint?
    @Binding internal var httpAction: HttpAction?
    @State internal var localHttpAction: HttpAction

    var body: some View {
        VStack(alignment: .leading) {
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
            }).onAppear {
                if let httpAction = httpAction {
                    localHttpAction = httpAction
                }
            }
        }.onChange(of: endpoint) { newValue in
            if let newValue = newValue {
                localHttpAction = newValue.action
            }
        }
    }
}

struct ResponseSequenceModePicker: View {
    @EnvironmentObject internal var globalStateManager: GlobalStateManager
    internal var server: Server
    @Binding internal var endpoint: Endpoint?
    @Binding internal var sequenceMode: Endpoint.ResponseSequenceMode?
    @State internal var localSequenceMode: Endpoint.ResponseSequenceMode

    var body: some View {
        VStack(alignment: .leading) {
            Text("Response Sequence Mode:")
                .padding(.leading, 10)
            Picker("", selection: $localSequenceMode) {
                ForEach(Endpoint.ResponseSequenceMode.allCases) { sequenceMode in
                    Text(sequenceMode.displayString)
                }
            }.onChange(of: localSequenceMode, perform: { mode in
                if var localEndpoint = endpoint {
                    localSequenceMode = mode
                    sequenceMode = mode
                    endpoint?.responseSequenceMode = mode
                    localEndpoint.responseSequenceMode = mode
                    globalStateManager.updateEndpointOnServer(server: server, endpoint: localEndpoint)
                }
            }).onAppear {
                if let sequenceMode = sequenceMode {
                    localSequenceMode = sequenceMode
                }
            }
        }.onChange(of: endpoint) { newValue in
            if let newValue = newValue {
                localSequenceMode = newValue.responseSequenceMode
            }
        }
    }
}

struct ResponseTabView: View {
    @EnvironmentObject internal var globalStateManager: GlobalStateManager
    internal var server: Server
    @Binding internal var endpoint: Endpoint?
    @Binding internal var selectedResponse: MockResponse?
    var body: some View {
        if let endpoint = endpoint {
            HStack(alignment: .top) {
                ScrollView(.horizontal) {
                    HStack(alignment: .top) {
                        ForEach(Array(endpoint.responses).indices, id: \.self) { index in
                            if let response = endpoint.responses[index] {
                                ResponseTab(endpoint: $endpoint, selectedResponse: $selectedResponse, index: index, response: response)
                                    .onTapGesture {
                                        selectedResponse = response
                                    }
                            }
                        }
                    }
                }

                Button {
                    globalStateManager.createNewResponseOn(endpoint: endpoint)
                    print("New Response")

                } label: {
                    Image(systemName: "play.circle.fill")
                        .aspectRatio(contentMode: .fill)
                }
                .foregroundColor(.gray)
            }
        }
    }
}

struct ResponseTab: View {
    @Binding internal var endpoint: Endpoint?
    @Binding internal var selectedResponse: MockResponse?
    internal var index: Int
    internal var response: MockResponse

    private var tabText: String {
        return "Response \(index + 1)"
    }

    var body: some View {
        VStack(alignment: .center) {
            Rectangle()
                .foregroundColor(selectedResponse == response ? .blue : .clear)
                .frame(width: 90, height: 3)
            Text(tabText)
                .padding(.top, 7)
                .padding(.bottom, 10)

        }
        .background(.yellow)
    }
}


