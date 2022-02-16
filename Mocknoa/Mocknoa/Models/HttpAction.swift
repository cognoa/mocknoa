//
//  HttpAction.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/15/22.
//

import Foundation

public enum HttpAction: String, Codable, CaseIterable, Identifiable {
    case get
    case post
    case patch
    case delete

    public var id: Self { self }
}
