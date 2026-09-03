//
//  Telegram.swift
//  AiDigestBot
//
//  Created by Kevin Artan on 03/09/26.
//

import Vapor

struct TelegramSendMessageRequest: Content {
    let chat_id: String
    let text: String
    let disable_web_page_preview: Bool?
}
