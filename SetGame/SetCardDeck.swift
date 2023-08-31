//
//  SetCardDeck.swift
//  SetGame
//
//  Created by Саша Восколович on 06.08.2023.
//

import Foundation

struct SetCardDeck {
    
    // Here we put all 81 cards
    private(set) var cards = [SetCard]()
    
    
    // MARK: Init our 81 cards all of them are uniq
    init() {
        for number in SetCard.Variant.allCases {
            for color in SetCard.Variant.allCases {
                for shape in SetCard.Variant.allCases {
                    for fill in SetCard.Variant.allCases {
                        cards.append(SetCard(number: number,
                                              color: color,
                                              shape: shape,
                                               fill: fill))
                    }
                }
            }
        }
    }
    
    // Take random card from the deck, because we want chaos choice:)
    mutating func draw() -> SetCard? {
        if cards.count > 0 {
            return cards.remove(at: cards.count.random())
        } else {
            return nil
        }
    }
}
