//
//  BorderView.swift
//  SetGame
//
//  Created by Саша Восколович on 14.08.2023.
//

import UIKit

class BorderView: UIView {
    
    // An array to hold the SetCardView instances that will be displayed in this BorderView.
    var cardViews = [SetCardView]()
    
    private var gridCards: Grid?
    
    var rowGrids: Int { return gridCards?.dimensions.rowCount ?? 0 }
       
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Create a grid to arrange the cards based on the aspect ratio and the frame of the BorderView.
        gridCards = Grid(
            layout: Grid.Layout.aspectRatio(Constant.cellAspectRatio),
            frame: bounds)
        // Set the cell count based on the number of cardViews.
        gridCards?.cellCount = cardViews.count
        layoutSetCards()
    }
    
    
    private func layoutSetCards() {
        if let grid = gridCards {
            let columnGrids = grid.dimensions.columnCount
            
            // Loop through rows and columns to position the cards within the grid.
            for row in 0..<rowGrids {
                for column in 0..<columnGrids {
                    if cardViews.count > (row * columnGrids + column) {
                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: Constant.duration,
                                                                       delay: TimeInterval(row) * 0.1,
                                                                       options: [.curveEaseInOut]) {
                            self.cardViews[row * columnGrids + column].frame = grid[row, column]!.insetBy(dx: Constant.spacingDx, dy: Constant.spacingDy)
                        }
                    }
                }
            }
        }
    }
    
    // Very simple, add to our view
    func add(new cards: [SetCardView]) {
         cardViews += cards
         cards.forEach { setCardView in
            addSubview(setCardView)
         }
         layoutIfNeeded()
    }
    
    // Say for itself
    func remove(_ cards: [SetCardView]) {
        cards.forEach { setCardView in
            cardViews.remove(elements: [setCardView])
            setCardView.removeFromSuperview()
        }
        layoutIfNeeded()
    }
    
    // The same))
    func reset() {
        cardViews.forEach { setCardView in
            setCardView.removeFromSuperview()
        }
        cardViews = []
        layoutIfNeeded()
    }
    
    
    // Constants for aspect ratio and spacing values.
    struct Constant {
        static let cellAspectRatio: CGFloat = 0.6
        static let spacingDx: CGFloat = 3.0
        static let spacingDy: CGFloat = 3.0
        static let duration: CGFloat = 0.3
        
    }
    
}
