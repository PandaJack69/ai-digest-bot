import Vapor

func routes(_ app: Application) throws {
//    app.get { req async in
//        "It works!"
//    }
//
//    app.get("hello") { req async -> String in
//        "Hello, world!"
//    }
    
    app.get { req in "AI Digest Bot is running" }
    try app.register(collection: DigestController())
}
