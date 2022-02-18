//
//  HttpAction.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/15/22.
//

import Foundation
import SwiftUI

public enum HttpAction: String, Codable, CaseIterable, Identifiable {
    case get
    case post
    case patch
    case delete

    public var id: Self { self }

    public var displayString: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .patch: return "PATCH"
        case .delete: return "DELETE"
        }
    }

    public var displayColor: Color {
        switch self {
        case .get: return .blue
        case .post: return .green
        case .patch: return .orange
        case .delete: return .red
        }
    }
}
