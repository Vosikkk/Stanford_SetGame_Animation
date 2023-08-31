//
//  SetGame.swift
//  SetGame
//
//  Created by Саша Восколович on 06.08.2023.
//

import Foundation

struct SetGame {
    
    // MARK: Property
    private(set) var numberOfSets = 0
    private(set) var cardsOnTheTable = [SetCard]()
    private(set) var selectedCards = [SetCard]()
    private(set) var tryMatchedCards = [SetCard]()
    private(set) var removedCards = [SetCard]()
    
    private var deck = SetCardDeck()
    
    // Show user how many cards in the deck
    var deckCount: Int { return deck.cards.count }
    
    // Computed property that determines whether the selected cards form a valid set or not.
    var isSet: Bool? {
        get {
            // Check if there are exactly 3 cards selected for matching.
            guard tryMatchedCards.count == 3 else { return nil }
            
            // Return the result of the isSet(cards:) method from the SetCard class.
            return SetCard.isSet(cards: tryMatchedCards)
        }
        set {
            if newValue != nil {
                if newValue! {
                    numberOfSets += 1
                }
                
                // store the selected cards for matching and clear the selectedCards array.
                tryMatchedCards = selectedCards
                selectedCards.removeAll()
            } else {
                // clear the tryMatchedCards array, because we check and result was wrong)
                tryMatchedCards.removeAll()
            }
        }
    }
   
    // Computed property that searches sets between cards on the table and return indexes of cards which are Set
    var hints: [[Int]] {
        var hints = [[Int]]()
        if cardsOnTheTable.count > 2 {
           // Take three cards
            for i in 0..<cardsOnTheTable.count {
                for j in (i + 1)..<cardsOnTheTable.count {
                    for k in (j + 1)..<cardsOnTheTable.count {
                        let cards = [cardsOnTheTable[i], cardsOnTheTable[j], cardsOnTheTable[k]]
                        // Check if they Set
                        if SetCard.isSet(cards: cards) {
                            // Add Set
                            hints.append([i,j,k])
                        }
                    }
                }
            }
        }
        
        // If we have set in matched cards we don't need have this cards on Hints
        if let isItSet = isSet, isItSet {
            
            // Find the indices of the cards that were selected for matching.
            let matchIndices = cardsOnTheTable.indices(of: tryMatchedCards)
                   // Generate all possible hints based on the current cards on the table.
            return hints.map{ Set($0) }
                .filter{ $0.intersection(Set(matchIndices)).isEmpty }//Filter out hints that contain any of the indices of the cards in the valid set.
                .map{ Array($0) } // Convert the valid hint sets back to arrays of indices
        }
        return hints
    }
    
    //MARK: Init
    init() {
        for _ in 0..<Constants.startNumberCards {
         if let card = deck.draw() {
            cardsOnTheTable += [card]
            }
        }
    }
    
    
  
   //MARK: Logic:)
   
    
    mutating func chooseCard(at index: Int) {
        
        // Check if the index corresponds to available cards on the table.
        assert(cardsOnTheTable.indices.contains(index),
               "SetGame.chooseCard(at: \(index)) : Choosen index out of range")
        
        // Get the chosen card based on its index.
        let cardChosen = cardsOnTheTable[index]
        
        // Check if the chosen card is not among the removed or already selected for matching cards.
        if !removedCards.contains(cardChosen) && !tryMatchedCards.contains(cardChosen) {
            
            if isSet != nil {
                // Check if a valid set has already been confirmed (isSet == true)
                if isSet! {
                    //replace or remove 3 cards.
                    replaceOrRemove3Cards()
                }
                // After processing, set isSet back to nil.
                 isSet = nil
            }
            
            // Check if two cards are already chosen and the chosen card is not in the list of selected cards.
            if selectedCards.count == 2, !selectedCards.contains(cardChosen) {
                selectedCards += [cardChosen]
                
                // Determine if the selected cards form a set.
                isSet = SetCard.isSet(cards: selectedCards)
            
            } else {
                // If the chosen card was already in the selected cards list, remove it.
                selectedCards.inOut(element: cardChosen)
            }
        }
    }
    
    
        // Shuffle baby
    mutating func shuffle() {
        cardsOnTheTable.shuffle()
    }
    
    private mutating func replaceOrRemove3Cards(){
        // We have 12 cards on the table and we have set, so replace set's cards on the new three
        if cardsOnTheTable.count == Constants.startNumberCards, let take3Cards = take3FromDeck() {
            cardsOnTheTable.replace(elements: tryMatchedCards, with: take3Cards)
        } else {
            // just remove cards
             cardsOnTheTable.remove(elements: tryMatchedCards)
        }
         removedCards += tryMatchedCards
         tryMatchedCards.removeAll()
    }
    
   
    // Very simple take three cards from our deck
    private mutating func take3FromDeck() -> [SetCard]?{
        var threeCards = [SetCard]()
        for _ in 0...2 {
            if let card = deck.draw() {
                threeCards += [card]
            } else {
                return nil
            }
        }
        return threeCards
    }
    
    // We want add three cards on the table
    mutating func deal3() {
        if let deal3Cards = take3FromDeck() {
            cardsOnTheTable += deal3Cards
        }
    }
    
   // Say for itself
    private struct Constants {
        static let startNumberCards = 12
    }
}

