//
//  DataManager.swift
//  GuessСard
//
//  Created by Андрей Евдокимов on 21.01.2022.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    var cards: [Card] = []
    
    private var deckId: String = ""
    
    func fetchDeck(with completion: @escaping () -> Void) {
        guard let url = URL(string: getUrls(from: .createDeck)) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "No error description")
                return
            }
            let stringJSON = String(decoding: data, as: UTF8.self)

            if let dataJSON = stringJSON.data(using: .utf8) {
                guard let json = try? JSONSerialization.jsonObject(with: dataJSON, options: []) as? [String: Any] else { return }
                
                if let deckId = json["deck_id"] as? String {
                    self.deckId = deckId
                    completion()
                }
            }
        }.resume()
    }
    
    func fetchCards(with completion: @escaping () -> Void) {
        guard let url = URL(string: getUrls(from: .getCards)) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "No error description")
                return
            }
            let stringJSON = String(decoding: data, as: UTF8.self)
            
            if let dataJSON = stringJSON.data(using: .utf8) {
                guard let json = try? JSONSerialization.jsonObject(with: dataJSON, options: []) as? [String: Any] else { return }

                if let cards = json["cards"] as? [Any] {
                    for cardData in cards {
                        guard let cardDataToDictionary = cardData as? [String: Any] else { return }
                        guard let card = try? Card(dictionary: cardDataToDictionary) else { return }

                        self.cards.append(card)
                    }
                    
                    completion()
                }
            }
        }.resume()
    }
    
    private func getUrls(from key: UrlKeys) -> String {
        switch key {
        case .createDeck:
            return "https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1"
        case .getCards:
            return "https://deckofcardsapi.com/api/deck/\(deckId)/draw/?count=2"
        }
    }
    
    private init () {}
}


extension DataManager {
    enum UrlKeys {
        case createDeck
        case getCards
    }
}
