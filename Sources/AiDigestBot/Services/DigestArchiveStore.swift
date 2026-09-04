//
//  DigestArchiveStore.swift
//  AiDigestBot
//
//  Created by Kevin Artan on 04/09/26.
//

import Vapor

actor DigestArchiveStore {
    private let fileURL: URL

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func append(_ record: DigestRecord) throws {
        var records = try loadAll()
        records.append(record)
        try save(records)
    }

    /// Most recent first.
    func recent(limit: Int = 30) throws -> [DigestRecord] {
        Array(try loadAll().suffix(limit).reversed())
    }

    private func loadAll() throws -> [DigestRecord] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        guard !data.isEmpty else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([DigestRecord].self, from: data)
    }

    private func save(_ records: [DigestRecord]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        try encoder.encode(records).write(to: fileURL, options: .atomic)
    }
}

// MARK: - Registering it as an Application-level service

struct DigestArchiveStoreKey: StorageKey {
    typealias Value = DigestArchiveStore
}

extension Application {
    var digestArchive: DigestArchiveStore {
        guard let store = self.storage[DigestArchiveStoreKey.self] else {
            fatalError("DigestArchiveStore not configured — check configure.swift")
        }
        return store
    }
}
