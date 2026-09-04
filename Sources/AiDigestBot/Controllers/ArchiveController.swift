//
//  ArchiveController.swift
//  AiDigestBot
//
//  Created by Kevin Artan on 04/09/26.
//

import Vapor

struct ArchiveController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("digests", use: listDigests)
    }

    func listDigests(req: Request) async throws -> Response {
        let records = try await req.application.digestArchive.recent(limit: 30)

        let entries = records.map { record in
            """
            <article class="digest-entry">
                <h2>\(record.date)</h2>
                <p class="paper-count">\(record.paperTitles.count) papers covered</p>
                <pre class="digest-text">\(record.digestText.htmlEscaped())</pre>
            </article>
            """
        }.joined(separator: "\n")

        let html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>AI Digest Archive</title>
        </head>
        <body>
            <h1>AI Digest Archive</h1>
            <p><a href="/">&larr; Back home</a></p>
            \(records.isEmpty ? "<p>No digests yet — check back after the first run.</p>" : entries)
        </body>
        </html>
        """

        var response = Response(status: .ok)
        response.headers.contentType = .html
        response.body = .init(string: html)
        return response
    }
}

private extension String {
    func htmlEscaped() -> String {
        replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
