//
//  LLM.swift
//  AiDigestBot
//
//  Created by Kevin Artan on 03/09/26.
//

import Vapor

struct ChatCompletionRequest: Content {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double?
    let reasoning_effort: String? //set low reasoning
}

struct ChatMessage: Content {
    let role: String
    let content: String
}

struct ChatCompletionResponse: Content {
    let choices: [Choice]

    struct Choice: Content {
        let message: ChatMessage
    }
}
