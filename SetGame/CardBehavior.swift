//
//  CardBehavior.swift
//  SetGame
//
//  Created by Саша Восколович on 24.08.2023.
//

import UIKit

class CardBehavior: UIDynamicBehavior {

    // MARK: - Properties
    
    // A collision behavior for handling collisions with boundaries
    lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    // An item behavior for controlling item-specific physics properties
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = true
        behavior.elasticity = 0.9
        behavior.resistance = 0
        return behavior
    }()
    
    // The point where items will be snapped
    var snapPoint = CGPoint()
    
    // MARK: - Private Methods
    
    // Snaps an item to the specified snap point with damping
    private func snap(_ item: UIDynamicItem) {
        let snap = UISnapBehavior(item: item, snapTo: snapPoint)
        snap.damping = 0.2
        addChildBehavior(snap)
    }
    
    // Applies a push to an item with a random angle and magnitude
    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        push.angle = CGFloat.pi * 3/4 - (CGFloat.pi * 2).arc4random
        push.magnitude = CGFloat(10.0) + CGFloat(2.0).arc4random
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
        
    }
    
    // MARK: - Public Methods
   
    // Adds an item to the dynamic behavior, removes it from collision after 2 seconds, and snaps it
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
            self.collisionBehavior.removeItem(item)
            self.snap(item)
        }
        push(item)
    }
    
    // Removes an item from the dynamic behavior
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    // MARK: - Initialization
    
    // Designated initializer
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    // Convenience initializer that adds the behavior to a specified animator
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    } 
}
