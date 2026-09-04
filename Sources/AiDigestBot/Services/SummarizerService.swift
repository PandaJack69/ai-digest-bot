//
//  SummarizerService.swift
//  AiDigestBot
//
//  Created by Kevin Artan on 03/09/26.
//

import Vapor

struct SummarizerService {
    let client: Client
    let apiKey: String
    let apiURL: String
    let model: String

    func summarize(papers: [DailyPaperEntry]) async throws -> String {
        let papersText = papers.enumerated().map { index, entry in
            "\(index + 1). \(entry.paper.title)\n\(entry.paper.summary)"
        }.joined(separator: "\n\n")

        let prompt = """
        Summarize the following AI research papers into a short, engaging \
        daily digest for a Telegram channel. One to two plain-text sentences \
        per paper, no markdown headers, keep the whole thing under 600 words.

        Papers:
        \(papersText)
        """

        let requestBody = ChatCompletionRequest(
            model: model,
            messages: [
                ChatMessage(role: "system", content: "You summarize AI research papers into concise digests."),
                ChatMessage(role: "user", content: prompt)
            ],
            temperature: 0.5,
            reasoning_effort: "low"
        )

        let response = try await client.post(URI(string: apiURL)) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: apiKey)
            try req.content.encode(requestBody)
        }

        guard response.status == .ok else {
            let body = response.body.map { String(buffer: $0) } ?? ""
            throw Abort(.badGateway, reason: "LLM API error \(response.status): \(body)")
        }

        let decoded = try response.content.decode(ChatCompletionResponse.self)
        guard let text = decoded.choices.first?.message.content else {
            throw Abort(.internalServerError, reason: "LLM response had no content")
        }
        return text
    }
}
