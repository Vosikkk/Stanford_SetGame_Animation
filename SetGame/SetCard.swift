//
//  SetCard.swift
//  SetGame
//
//  Created by Саша Восколович on 06.08.2023.
//

import Foundation

struct SetCard: Equatable, CustomStringConvertible {
    
    let number: Variant // number - 1, 2, 3
    let color: Variant  // color  - 1, 2, 3
    let shape: Variant  // symbol - 1, 2, 3
    let fill: Variant   // fill   - 1, 2, 3
   
    var description: String { return "\(number)-\(color)-\(shape)-\(fill)" }
    
    
    //MARK: Nested Type
    // Helps us to create and identify every uniq card
    enum Variant: Int, CaseIterable, CustomStringConvertible  {
        case v1 = 1
        case v2
        case v3
        
        // Beautiful print
        var description: String { return String(self.rawValue) }
       
        // Because we don't use every time "rawValue - 1" when will creating our button by NSAttributedString
        var index: Int { return (self.rawValue - 1) }
    }
    
    
    
    //MARK: One of the most important function, which will let us to know is there is set or not
    static func isSet(cards: [SetCard]) -> Bool {
        
        // less than 3 cards for checking good bye she doesn't wnat check it
        guard cards.count == 3 else { return false }
        
        // Counts each the same property of three cards
        let sum = [
        cards.reduce(0, { $0 + $1.number.rawValue}),
        cards.reduce(0, { $0 + $1.color.rawValue}),// for example (card1.color = 3) + (card2.color = 1) + (card3.color = 1)
        cards.reduce(0, { $0 + $1.shape.rawValue}),
        cards.reduce(0, { $0 + $1.fill.rawValue})
        ]
        
        // If we know all cards must have the same or different values so
        // 1 + 2 + 3 % 3 == 0 set or 2 + 2 + 2 % 3 == 0 set
        return sum.reduce(true, { $0 && ($1 % 3 == 0) })
    }
}
