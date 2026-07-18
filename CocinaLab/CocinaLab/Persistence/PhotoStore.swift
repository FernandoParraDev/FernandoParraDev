import Foundation
import UIKit

/// Saves recipe photos as JPEG files under the app's Documents directory.
/// SwiftData models only ever hold the file name, never the image bytes.
enum PhotoStore {
    private static let photosDirectory: URL = {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directory = documents.appendingPathComponent("Photos", isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }()

    @discardableResult
    static func save(_ data: Data) -> String? {
        guard let image = UIImage(data: data),
              let jpegData = image.jpegData(compressionQuality: 0.85) else {
            return nil
        }
        let fileName = "\(UUID().uuidString).jpg"
        let url = photosDirectory.appendingPathComponent(fileName)
        do {
            try jpegData.write(to: url, options: .atomic)
            return fileName
        } catch {
            return nil
        }
    }

    static func url(for fileName: String) -> URL {
        photosDirectory.appendingPathComponent(fileName)
    }

    static func loadImage(fileName: String) -> UIImage? {
        UIImage(contentsOfFile: url(for: fileName).path)
    }

    static func delete(fileName: String) {
        try? FileManager.default.removeItem(at: url(for: fileName))
    }
}
