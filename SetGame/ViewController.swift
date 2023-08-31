//
//  ViewController.swift
//  SetGame
//
//  Created by Саша Восколович on 06.08.2023.
//

import UIKit

class ViewController: UIViewController, UIDynamicAnimatorDelegate {
    
    // MARK: Outlets for various UI elements
    
    
    // The game board view where Set cards are displayed.
    @IBOutlet weak var boardView: BorderView! {
        didSet {
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(reshuffle))
            boardView.addGestureRecognizer(rotate)
        }
    }
    // Deck of cards 
    @IBOutlet weak var deckImageView: DeckImageView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(deal))
            tap.numberOfTapsRequired = 1
            tap.numberOfTouchesRequired = 1
            deckImageView.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var stackMessage: UIStackView!
    
    @IBOutlet weak var newGameButton: BorderButton!
    
    @IBOutlet weak var hintButton: BorderButton!
    
    @IBOutlet weak var setsButton: BorderButton!
    
    private lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self.boardView)
        animator.delegate = self
        return animator
    }()
    
    private lazy var cardBehavior = CardBehavior(in: animator)
    
    
    // MARK: Private Variables
    private var game = SetGame()
    
    // Variables for button configurations
    private weak var timer: Timer?
    private var lastHint = 0
    private let flashTime = 1.5
    
    private var matchedCards: [SetCardView] {
        return boardView.cardViews.filter { $0.isMatched == true }
    }
    private var dealCards: [SetCardView] {
        return boardView.cardViews.filter { $0.alpha == 0 }
    }
    
    private var deckCenter: CGPoint {
        return view.convert(stackMessage.center, to: boardView)
       
    }
    private var hintButtonText: String {
        return " \(game.hints.count) set" + (game.hints.count > 1 ? "s " : "  ")
    }
    
    private var temporaryCards = [SetCardView]()
    
    private var discardPileCenter: CGPoint {
        return stackMessage.convert(setsButton.center, to: boardView)
    }
    
    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateViewFromModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardBehavior.snapPoint = discardPileCenter
    }
    
    
    // MARK: Private Functions
    
    // Function to update the entire view based on the game model
    private func updateViewFromModel() {
        updateCardViewFromModel()
        updateHintButton()
        deckImageView.deckCount = "\(game.deckCount)"
        setsButton.setTitle(" Set \(game.numberOfSets)", for: .normal)
        setsButton.alpha = game.numberOfSets == 0 || (game.isSet != nil && game.isSet!) ? 0 : 1
    }
    
    // Update card views based on the game model.
    private func updateCardViewFromModel() {
        var cardViews = [SetCardView]()
        
        if boardView.cardViews.count - game.cardsOnTheTable.count > 0 {
            boardView.remove(matchedCards)
        }
        
        let numberCardViews = boardView.cardViews.count
        
        for index in game.cardsOnTheTable.indices {
            let card = game.cardsOnTheTable[index]
            
            if index > numberCardViews - 1 {// New card
                
                let cardView = SetCardView()
                updateCardView(cardView, for: card)
                cardView.alpha = 0
                addTapGestureRecognizer(for: cardView)
                cardViews += [cardView]
                
            } else {
                let cardView = boardView.cardViews[index]// Just update cards, maybe selected or matched etc.
                if cardView.alpha < 1 && cardView.alpha > 0 && game.isSet != true {
                    cardView.alpha = 0
                }
                updateCardView(cardView, for: card)
            }
        }
        
        boardView.add(new: cardViews)
        flyAnimation()
        dealAnimation()
    }
    
    // Add a tap gesture recognizer to a card view.
    private func addTapGestureRecognizer(for cardView: SetCardView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapedCard))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        cardView.addGestureRecognizer(tap)
    }
    
    // Handle tap gestures on card views.
    @objc private func tapedCard(recognized recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let card = recognizer.view! as? SetCardView {
                game.chooseCard(at: boardView.cardViews.firstIndex(of: card)!)
            }
        default: break
        }
        updateViewFromModel()
        
    }
    
    
    // Update a card view based on the card model.
    private func updateCardView(_ view: SetCardView, for card: SetCard) {
        view.colorInt = card.color.rawValue
        view.fillInt = card.fill.rawValue
        view.symbolInt = card.shape.rawValue
        view.count = card.number.rawValue
        view.isSelected = game.selectedCards.contains(card)
        if let isItSet = game.isSet {
            if game.tryMatchedCards.contains(card) {
                view.isMatched = isItSet
            }
        } else {
            view.isMatched = nil
        }
    }
    
    
    // Function to update the hint button based on available hints
    private func updateHintButton() {
        hintButton.setTitle(hintButtonText, for: .normal)
        lastHint = 0
    }
    
    
    // Our cards will fly on the screen)
    private func flyAnimation() {
        let alreadyFlewAwayCards = matchedCards.filter{ $0.alpha < 1 && $0.alpha > 0 }.count
        
        if game.isSet != nil, game.isSet!, alreadyFlewAwayCards == 0 {
            
            matchedCards.forEach { card in
                card.alpha = 0.2
                temporaryCards += [card.copyCard()]
            }
            
            temporaryCards[2].addToDiscardPile = { [weak self] in
                if let countSets = self?.game.numberOfSets, countSets > 0 {
                    self?.setsButton.setTitle(" Sets: \(countSets)", for: .normal)
                    self?.setsButton.alpha = 1
                }
            }
            
            temporaryCards.forEach { card in
                boardView.addSubview(card)
                cardBehavior.addItem(card)
            }
        }
    }
    
    // Here cards stayed on the right lower corner
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        temporaryCards.forEach { card in
            UIView.transition(with: card,
                              duration: 0.5,
                              options: [.transitionFlipFromLeft]) {
                card.isFaceUp = false
                card.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi / 2.0)
                card.bounds = CGRect(x: 0.0, y: 0.0, width: card.bounds.width * 0.8, height: card.bounds.height * 0.8)
                
            } completion: { isComplete in
                self.cardBehavior.removeItem(card)
                card.addToDiscardPile?()
                card.removeFromSuperview()
                self.temporaryCards.remove(elements: [card])
                
            }
        }
    }
    
    // Cards appear on the screen from the deck(lower part of the screen)
    private func dealAnimation() {
        var currentCard = 0
        let timeInterval = 0.15 * Double(boardView.rowGrids + 1)
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { timer in
            self.dealCards.forEach { card in
                card.animatedCard(from: self.deckCenter,
                                  delay: TimeInterval(currentCard) * 0.25)
                currentCard += 1
            }
        }
    }
    
    
    // MARK: Actions
    
    // Action for dealing 3 more cards
    @objc func deal() {
        game.deal3()
        updateViewFromModel()
    }
    
    // It find how you can to win
    @IBAction func hint() {
        timer?.invalidate()
        if game.hints.count > 0 {
            game.hints[lastHint].forEach { (index) in
                boardView.cardViews[index].hint()
                
                timer = Timer.scheduledTimer(withTimeInterval: flashTime,
                                             repeats: false) { [weak self] time in
                    self?.lastHint = (self?.lastHint)!.incrementCicle(in:(self?.game.hints.count)!)
                    self?.updateCardViewFromModel()
                }
            }
        }
    }
    
    // Action for starting a new game
    @IBAction func newGame() {
        game = SetGame()
        boardView.reset()
        temporaryCards.forEach { card in card.removeFromSuperview() }
        temporaryCards = []
        updateViewFromModel()
    }
    
    // Reshuffle action.
    @objc func reshuffle(_ sender: UIGestureRecognizer) {
        guard sender.view != nil else { return }
        switch sender.state {
        case .ended:
            game.shuffle()
            updateViewFromModel()
        default: break
      }
    }
}

