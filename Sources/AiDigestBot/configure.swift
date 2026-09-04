import Vapor

/// configures your application
func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory, defaultFile: "index.html"))
    
    // LLM calls can be slow — default client timeout is short
    app.http.client.configuration.timeout = .init(connect: .seconds(10), read: .seconds(60))
    
    // Digest archive storage
    let archiveDir = URL(fileURLWithPath: app.directory.workingDirectory)
        .appendingPathComponent("data", isDirectory: true)
    try FileManager.default.createDirectory(at: archiveDir, withIntermediateDirectories: true)
    app.storage[DigestArchiveStoreKey.self] = DigestArchiveStore(
        fileURL: archiveDir.appendingPathComponent("digests.json")
    )

    // register routes
    try routes(app)
}
