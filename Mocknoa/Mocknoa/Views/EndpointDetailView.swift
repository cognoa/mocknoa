//
//  EndpointDetailView.swift
//  Mocknoa
//
//  Created by Wilma Rodriguez on 2/16/22.
//

import SwiftUI

struct EndpointDetailView: View {
    @Binding internal var endpoint: Endpoint?
    @State private var path: String = ""
    @State private var statusCode: String = ""

    var body: some View {
        if let endpoint = endpoint {
            VStack {
                HStack {
                    Text("Path: ")
                        .padding(.horizontal, 2)
                    TextField("New path", text: $path)
                        .background(Color.gray)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .cornerRadius(3)
                        .onSubmit {
                            self.endpoint?.path = path
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
