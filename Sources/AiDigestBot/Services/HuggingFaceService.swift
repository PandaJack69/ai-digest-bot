//
//  HuggingNewsService.swift
//  AiDigestBot
//
//  Created by Kevin Artan on 03/09/26.
//

import Vapor

struct HuggingFaceService {
    let client: Client

    func fetchTodaysPapers(limit: Int = 5) async throws -> [DailyPaperEntry] {
        let response = try await client.get(
            "https://huggingface.co/api/daily_papers?limit=\(limit)"
        )
        guard response.status == .ok else {
            throw Abort(.badGateway, reason: "Hugging Face API returned \(response.status)")
        }
        return try response.content.decode([DailyPaperEntry].self)
    }
}
