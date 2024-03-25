//
//  Credential.swift
//  eBalo
//
//  Created by Ivan Lele on 22.03.2024.
//

import Foundation

struct Credential: Codable {
    let id: String
    let createdAt: Date
}

extension Credential {
    static let sample = Self(
        id: "b7484d84-9a59-46bf-b0b3-920ee83714d8",
        createdAt: Date()
    )
}
