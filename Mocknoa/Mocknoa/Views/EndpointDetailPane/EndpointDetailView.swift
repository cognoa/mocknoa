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
    static let leadingPadding: CGFloat = 10
    @State var selectedResponse: MockResponse?

    var body: some View {
        if let endpoint = endpoint, let currentServer = currentServer {
            VStack (alignment: .leading) {
                GroupBox {
                    VStack (alignment: .leading) {
                        Text("Path: ")
                            .padding(.leading, Self.leadingPadding)
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


                ResponseTabView(endpoint: $endpoint, selectedResponse: $selectedResponse)
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
    }
}

struct ResponseSequenceModePicker: View {
    @EnvironmentObject internal var globalStateManager: GlobalStateManager
    internal var server: Server
    @Binding internal var endpoint: Endpoint?
    @Binding internal var sequenceMode: Endpoint.ResponseSequenceMode?
    @State internal var localSequenceMode: Endpoint.ResponseSequenceMode

    var body: some View {
        Text("Response Sequence Mode:")
            .padding(.leading, 10)
        Picker("", selection: $localSequenceMode) {
            ForEach(Endpoint.ResponseSequenceMode.allCases) { sequenceMode in
                Text(sequenceMode.displayString)
            }
        }.onChange(of: localSequenceMode, perform: { sequenceMode in
            if var localEndpoint = endpoint {
                localSequenceMode = sequenceMode
                self.sequenceMode = sequenceMode
                endpoint?.responseSequenceMode = sequenceMode
                localEndpoint.responseSequenceMode = sequenceMode
                globalStateManager.updateEndpointOnServer(server: server, endpoint: localEndpoint)
            }
        }).onAppear {
            if let sequenceMode = sequenceMode {
                localSequenceMode = sequenceMode
            }
        }
    }

}

struct ResponseTabView: View {
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
                            }
                        }
                    }
                }

                Button {
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
//        guard let endpoint = endpoint else { return "Response" }
//        if endpoint.responses.count > 1 { return "Response \(index)" }
        return "Response \(index + 1)"
//        else { return "Response" }
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
//        .frame(width: 75, height: 60)
        .onTapGesture {
            selectedResponse = response
        }
        .background(.yellow)
    }
}


