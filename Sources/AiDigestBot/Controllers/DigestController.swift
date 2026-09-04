//
//  DigestController.swift
//  AiDigestBot
//
//  Created by Kevin Artan on 03/09/26.
//

import Vapor

struct DigestController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.grouped("digest").post("run", use: runDigest)
    }

    func runDigest(req: Request) async throws -> HTTPStatus {
        // Shared-secret check so only your own cron job can trigger this
        guard let expectedToken = Environment.get("DIGEST_TRIGGER_TOKEN"), !expectedToken.isEmpty else {
            throw Abort(.internalServerError, reason: "DIGEST_TRIGGER_TOKEN is not configured")
        }
        guard req.headers.first(name: "X-Digest-Token") == expectedToken else {
            throw Abort(.unauthorized)
        }

        req.logger.info("Starting AI digest run")

        let papers = try await HuggingFaceService(client: req.client).fetchTodaysPapers(limit: 5)
        req.logger.info("Fetched \(papers.count) papers from Hugging Face") // debug
        guard !papers.isEmpty else {
            req.logger.info("No papers today — skipping")
            return .noContent
        }

        guard
            let llmKey = Environment.get("LLM_API_KEY"),
            let llmURL = Environment.get("LLM_API_URL"),
            let llmModel = Environment.get("LLM_MODEL")
        else {
            throw Abort(.internalServerError, reason: "LLM_API_KEY, LLM_API_URL or LLM_MODEL not configured")
        }
        let digestText = try await SummarizerService(
            client: req.client, apiKey: llmKey, apiURL: llmURL, model: llmModel
        ).summarize(papers: papers)
        req.logger.info("Got summary from LLM (\(digestText.count) chars)") // debug

        guard
            let botToken = Environment.get("TELEGRAM_BOT_TOKEN"),
            let chatId = Environment.get("TELEGRAM_CHAT_ID")
        else {
            throw Abort(.internalServerError, reason: "TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID not configured")
        }
        try await TelegramService(client: req.client, botToken: botToken, chatId: chatId)
            .send(text: "🧠 AI Daily Digest\n\n\(digestText)")
        
        req.logger.info("Telegram send complete") // debug
        
        // new
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let record = DigestRecord(
            id: UUID(),
            date: formatter.string(from: Date()),
            paperTitles: papers.map { $0.paper.title },
            digestText: digestText,
            createdAt: Date()
        )
        try await req.application.digestArchive.append(record)

        req.logger.info("Digest sent successfully")
        return .ok
    }
}
