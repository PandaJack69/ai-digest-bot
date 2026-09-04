//
//  DigestRecord.swift
//  AiDigestBot
//
//  Created by Kevin Artan on 04/09/26.
//

import Vapor

struct DigestRecord: Content, Codable {
    let id: UUID
    let date: String          // "yyyy-MM-dd"
    let paperTitles: [String]
    let digestText: String
    let createdAt: Date
}
