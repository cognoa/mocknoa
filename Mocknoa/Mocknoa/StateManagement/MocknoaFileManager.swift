//
//  MocknoaFileManager.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/16/22.
//

import Foundation

public class MocknoaFileManager {
    public static let globalEnvironmentFileName = "GlobalEnvironment.mocknoa"

    public static func createMocknoaDocumentsDirectory() -> URL? {
        guard let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return nil
        }
        guard let documentsURL = URL(string: documentsDirectory) else { return nil }
        let mocknoaPath = documentsURL.appendingPathComponent("Mocknoa")

        if !FileManager.default.fileExists(atPath: mocknoaPath.absoluteString) {
            do {
                try FileManager.default
                    .createDirectory(
                        atPath: mocknoaPath.absoluteString,
                        withIntermediateDirectories: true,
                        attributes: nil)
                return mocknoaPath
            } catch {
                print(error)
                return nil
            }
        } else {
            return mocknoaPath
        }
    }

    public static func saveGlobalEnvironment(_ globalEnvironment: GlobalEnvironment) {
        let encoder = JSONEncoder()
        guard let mocknoaDirectoryPath = createMocknoaDocumentsDirectory() else { return }
        let fileURL = mocknoaDirectoryPath.appendingPathComponent(globalEnvironmentFileName)
        do {
            let data = try encoder.encode(globalEnvironment)
            if FileManager.default.fileExists(atPath: fileURL.absoluteString) {
                try FileManager.default.removeItem(at: fileURL)
            }
            FileManager.default.createFile(atPath: fileURL.path, contents: data, attributes: nil)
        } catch {
            print(error)
        }
    }

    public static func retrieveGlobalEnvironment() -> GlobalEnvironment? {
        guard let mocknoaDirectoryPath = createMocknoaDocumentsDirectory() else { return nil }
        let fileURL = mocknoaDirectoryPath.appendingPathComponent(globalEnvironmentFileName)
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            return nil
        }

        if let data = FileManager.default.contents(atPath: fileURL.path) {
            let decoder = JSONDecoder()
            do {
                let globalEnvironment = try decoder.decode(GlobalEnvironment.self, from: data)
                return globalEnvironment
            } catch {
                print(error)
                return nil
            }
        }
        return nil
    }
}
