//
//  EndpointDetailView.swift
//  Mocknoa
//
//  Created by Wilma Rodriguez on 2/16/22.
//

import SwiftUI

struct EndpointDetailView: View {
//    @Binding var currentServer: Server
    @Binding var endpoint: Endpoint?

    var body: some View {
        if let endpoint = endpoint {
            VStack {
                Text(endpoint.path)
                Text("Status Code: \(endpoint.statusCode)")
                HttpActionPicker(httpAction: endpoint.action)
                JSONInputTextEditor()
            }
        } else {
            Text("")
        }
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

struct JSONInputTextEditor: View {
    @State var text: String = "Test JSON"

    var body: some View {
        VStack {
            Text("Input JSON Below")
            TextEditor(text: $text)
        }
    }
}
