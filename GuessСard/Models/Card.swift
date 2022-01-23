//
//  Card.swift
//  GuessСard
//
//  Created by Андрей Евдокимов on 21.01.2022.
//

import Foundation

struct Card {
    let image: URL
}

extension Card: Codable {
    init(dictionary: [String: Any]) throws {
        self = try JSONDecoder().decode(Card.self, from: JSONSerialization.data(withJSONObject: dictionary))
    }
}
