//
//  JournalPhotoStore.swift
//  skinCare
//
//  Saves / loads / deletes skin-log photos from the app's sandboxed Documents directory.
//

import UIKit

enum JournalPhotoStore {

    private static var directory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("JournalPhotos", isDirectory: true)
    }

    /// Saves a UIImage as JPEG and returns the filename, or nil on failure.
    static func save(_ image: UIImage) -> String? {
        let dir = directory
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let name = UUID().uuidString + ".jpg"
        guard let data = image.jpegData(compressionQuality: 0.82) else { return nil }
        try? data.write(to: dir.appendingPathComponent(name))
        return name
    }

    /// Loads a UIImage by filename. Returns nil if not found.
    static func load(named name: String) -> UIImage? {
        let url = directory.appendingPathComponent(name)
        return (try? Data(contentsOf: url)).flatMap(UIImage.init)
    }

    /// Deletes the file for a given filename.
    static func delete(named name: String) {
        try? FileManager.default.removeItem(at: directory.appendingPathComponent(name))
    }
}
