import Vapor

/// configures your application
func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // LLM calls can be slow — default client timeout is short
    app.http.client.configuration.timeout = .init(connect: .seconds(10), read: .seconds(60))

    // register routes
    try routes(app)
}
