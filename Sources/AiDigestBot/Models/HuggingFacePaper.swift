//
//  HuggingNewsPaper.swift
//  AiDigestBot
//
//  Created by Kevin Artan on 03/09/26.
//

import Vapor

/// One entry from https://huggingface.co/api/daily_papers
struct DailyPaperEntry: Content {
    let paper: PaperInfo
    let title: String?
    let publishedAt: String?

    struct PaperInfo: Content {
        let id: String
        let title: String
        let summary: String
        let upvotes: Int?
    }
}
