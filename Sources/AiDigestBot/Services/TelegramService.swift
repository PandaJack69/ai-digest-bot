//
//  TelegramService.swift
//  AiDigestBot
//
//  Created by Kevin Artan on 03/09/26.
//

import Vapor

struct TelegramService {
    let client: Client
    let botToken: String
    let chatId: String

    func send(text: String) async throws {
        let url = "https://api.telegram.org/bot\(botToken)/sendMessage"

        for chunk in text.splitIntoTelegramChunks() {
            let body = TelegramSendMessageRequest(
                chat_id: chatId,
                text: chunk,
                disable_web_page_preview: true
            )
            let response = try await client.post(URI(string: url)) { req in
                try req.content.encode(body)
            }
            guard response.status == .ok else {
                let respBody = response.body.map { String(buffer: $0) } ?? ""
                throw Abort(.badGateway, reason: "Telegram API error \(response.status): \(respBody)")
            }
        }
    }
}

private extension String {
    /// Telegram caps messages at 4096 chars — split on line breaks to stay under that.
    func splitIntoTelegramChunks(limit: Int = 4000) -> [String] {
        guard count > limit else { return [self] }
        var chunks: [String] = []
        var current = ""
        for line in split(separator: "\n", omittingEmptySubsequences: false) {
            if current.count + line.count + 1 > limit {
                chunks.append(current)
                current = String(line)
            } else {
                current += (current.isEmpty ? "" : "\n") + line
            }
        }
        if !current.isEmpty { chunks.append(current) }
        return chunks
    }
}
