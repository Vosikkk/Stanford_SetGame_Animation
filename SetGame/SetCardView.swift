//
//  SetCardView.swift
//  SetGame
//
//  Created by Саша Восколович on 14.08.2023.
//

import UIKit

@IBDesignable class SetCardView: UIView {
    
    //MARK: Variables
   
    // The background color of the card.
    @IBInspectable var faceBackGroundColor: UIColor = UIColor.white { didSet { setNeedsDisplay() } }
    
    @IBInspectable var isFaceUp: Bool = true { didSet { setNeedsDisplay(); setNeedsLayout() }}
    
    // Whether the card is selected.
    @IBInspectable var isSelected: Bool = false { didSet { setNeedsDisplay(); setNeedsLayout() }}
    
    // Whether the card is matched.
    var isMatched: Bool? { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    
    // The shape symbol on the card.
    private var symbol = Symbols.diamond { didSet { setNeedsDisplay() } }
    
    
    // The fill pattern of the shape.
    private var fill = Fill.striped { didSet { setNeedsDisplay() } }
    
    // The color of the shape.
    private var color = Colors.red { didSet { setNeedsDisplay() } }
    
    // The number of symbols on the card.
    var count = 1 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    // The space between striped lines.
    private let interStripeSpace: CGFloat = 5.0
    
    // The border width of the card.
    private let borderWidth: CGFloat = 5.0
   
    // The corner radius of the card.
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    
    // The space between symbols on the card.
    private var interPipHeight: CGFloat {
        return (faceFrame.height - (3 * pipHeight)) / 2
    }
    
    
    // integer values to represent symbol types, fill types, and colors.
    @IBInspectable
    var symbolInt: Int = 1 {
        didSet {
            switch symbolInt {
            case 1: symbol = .oval
            case 2: symbol = .squiggle
            case 3: symbol = .diamond
            default: break
            }
        }
    }
    @IBInspectable
    var fillInt: Int = 1 {
        didSet {
            switch fillInt {
            case 1: fill = .unfilled
            case 2: fill = .striped
            case 3: fill = .solid
            default: break
            }
        }
    }
    @IBInspectable
    var colorInt: Int = 1 {
        didSet {
            switch colorInt {
            case 1: color = Colors.red
            case 2: color = Colors.green
            case 3: color = Colors.purple
            default: break
            }
        }
    }
    
    // The maximum frame size for the card's face.
    private var maxFaceFrame: CGRect {
        return bounds.zoom(by: SizeRatio.maxFaceSizeToBoundsSize)
    }
    
    // The frame for the card's face.
    private var faceFrame: CGRect {
        let faceWidth = maxFaceFrame.height * AspectRatio.faceFrame
        return maxFaceFrame.insetBy(dx: (maxFaceFrame.width - faceWidth) / 2, dy: 0)
    }
    
    // The height of a single symbol.
    private var pipHeight: CGFloat {
        return faceFrame.height * SizeRatio.pipHeightToFaceHeight
    }
    

    // MARK: Functions
    
    // Custom drawing of the card's face.
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        faceBackGroundColor.setFill()
        roundedRect.fill()
        
        if isFaceUp {
            drawPips()
        } else {
            if let backCardImage = UIImage(named: "card-back",
                                      in: Bundle(for: self.classForCoder),
                                      compatibleWith: traitCollection) {
                backCardImage.draw(in: bounds)
            }
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureState()
    }
    
    // Draw the symbols on the card's face.
    private func drawPips() {
        color.setFill()
        color.setStroke()
        
        let size = CGSize(width: faceFrame.width, height: pipHeight)
        let origin = CGPoint(x: faceFrame.minX, y: faceFrame.midY - pipHeight / 2)
        let rect = CGRect(origin: origin, size: size)
        
        switch count {
        case 1:
            drawShape(in: rect)
        case 2:
            let firstRect = rect.offsetBy(dx: 0, dy: -(pipHeight + interPipHeight) / 2)
            drawShape(in: firstRect)
            let secondRect = rect.offsetBy(dx: 0, dy: (pipHeight + interPipHeight) / 2)
            drawShape(in: secondRect)
        case 3:
            drawShape(in: rect)
            let secondRect = rect.offsetBy(dx: 0, dy: -(pipHeight + interPipHeight))
            drawShape(in: secondRect)
            let thirdRect = rect.offsetBy(dx: 0, dy: pipHeight + interPipHeight)
            drawShape(in: thirdRect)
            
        default: break
        }
        
    }
    
    // Draw a shape inside a given rectangle.
    private func drawShape(in rect: CGRect) {
        let path: UIBezierPath
        switch symbol {
        case .oval:
            path = pathForOval(in: rect)
        case .squiggle:
            path = pathForSquiggle(in: rect)
        case .diamond:
            path = pathForDiamond(in: rect)
        }
        path.lineWidth = 3.0
        path.stroke()
        
        switch fill {
        case .solid:
            path.fill()
        case .striped:
            stripeShape(path: path, in: rect)
        default: break
        }
    }
    
    func animatedCard(from deckCenter: CGPoint, delay: TimeInterval) {
        let currentCenter = center
        let currentBounds = bounds
        
        center = deckCenter
        alpha = 1
        
        bounds = CGRect(x: 0.0, y: 0.0, width: 0.6 * bounds.width, height: 0.6 * bounds.height)
        isFaceUp = false
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1,
                                                       delay: delay) {
            self.center = currentCenter
            self.bounds = currentBounds
            
        } completion: { position in
            
            UIView.transition(with: self,
                              duration: 0.3,
                              options: [.transitionFlipFromLeft]) {
                self.isFaceUp = true
            }
        }
    }
    
    // Apply a hint style to the card.
    func hint() {
        layer.borderWidth = borderWidth
        layer.borderColor = Colors.hint
    }
    
    // Configure the appearance of the card based on its state (selected, matched, or mismatched).
    private func configureState() {
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        isOpaque = false
        contentMode = .redraw
        
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        
        if isSelected {
            layer.borderColor = Colors.selected
        }
        
        if let matched = isMatched {
            if matched {
                layer.borderColor = Colors.matched
            } else {
                layer.borderColor = Colors.missMatched
            }
        }
    }
    
    func copyCard() -> SetCardView {
        let copy = SetCardView()
        copy.symbolInt = symbolInt
        copy.colorInt = colorInt
        copy.fillInt = fillInt
        copy.count = count
        copy.isSelected = false
        copy.isFaceUp = true
        copy.bounds = bounds
        copy.frame = frame
        copy.alpha = 1
        return copy
        
    }
    
    
    var addToDiscardPile: (() -> Void)?
    
    
//    func animateFly(to discardPileCenter: CGPoint, delay: TimeInterval) {
//        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1,
//                                                       delay: delay) {
//            self.center = discardPileCenter
//        } completion: { position in
//            UIView.transition(with: self,
//                              duration: 0.75,
//                              options: [.transitionFlipFromLeft]) {
//                self.isFaceUp = false
//                self.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi / 2.0)
//                self.bounds = CGRect(x: 0.0,
//                                     y: 0.0,
//                                     width: 0.7 * self.bounds.width,
//                                     height: 0.7 * self.bounds.height)
//            } completion: { finished in
//                self.addToDiscardPile?()
//            }
//        }
//    }
    
    // Apply a striped pattern to a shape.
    private func stripeShape(path: UIBezierPath, in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        path.addClip()
        stripeRect(rect)
        context?.restoreGState()
    }
    
    // Draw stripes within a given rectangle.
    private func stripeRect(_ rect: CGRect) {
        let stripe = UIBezierPath()
        stripe.lineWidth = 1.0
        stripe.move(to: CGPoint(x: rect.minX, y: bounds.minY))
        stripe.addLine(to: CGPoint(x: rect.minX, y: bounds.maxY))
        let stripCount = Int(faceFrame.width / interStripeSpace)
        for _ in 1...stripCount {
            let translation = CGAffineTransform(translationX: interStripeSpace, y: 0)
            stripe.apply(translation)
            stripe.stroke()
        }
    }
    
    // Create a path for a diamond shape within a rectangle.
    private func pathForDiamond(in rect: CGRect) -> UIBezierPath {
        let diamond = UIBezierPath()
        diamond.move(to: CGPoint(x: rect.minX, y: rect.midY))
        diamond.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        diamond.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        diamond.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        diamond.close()
        return diamond
        
    }
    
    // Create a path for a squiggle shape within a rectangle.
    private func pathForSquiggle(in rect: CGRect) -> UIBezierPath {
        let upperSquiggle = UIBezierPath()
        let sqdx = rect.width * 0.1
        let sqdy = rect.height * 0.2
        upperSquiggle.move(to: CGPoint(x: rect.minX, y: rect.midY))
        upperSquiggle.addCurve(to: CGPoint(x: rect.minX + rect.width * 1/2, y: rect.minY + rect.height / 8),
                               controlPoint1: CGPoint(x: rect.minX, y: rect.minY),
                               controlPoint2: CGPoint(x: rect.minX + rect.width * 1/2 - sqdx, y: rect.minY + rect.height / 8 - sqdy))
        upperSquiggle.addCurve(to: CGPoint(x: rect.minX + rect.width * 4/5, y: rect.minY + rect.height / 8),
                               controlPoint1: CGPoint(x: rect.minX + rect.width * 1/2 + sqdx, y: rect.minY + rect.height / 8 + sqdy),
                               controlPoint2: CGPoint(x: rect.minX + rect.width * 4/5 - sqdx, y: rect.minY + rect.height / 8 + sqdy))
        upperSquiggle.addCurve(to: CGPoint(x: rect.minX + rect.width, y: rect.minY + rect.height / 2),
                               controlPoint1: CGPoint(x: rect.minX + rect.width * 4/5 + sqdx, y: rect.minY + rect.height / 8 - sqdy),
                               controlPoint2: CGPoint(x: rect.minX + rect.width, y: rect.minY))
        
        let lowerSquiggle = UIBezierPath(cgPath: upperSquiggle.cgPath)
        lowerSquiggle.apply(CGAffineTransform.identity.rotated(by: CGFloat.pi))
        lowerSquiggle.apply(CGAffineTransform.identity.translatedBy(x: bounds.width, y: bounds.height))
        upperSquiggle.move(to: CGPoint(x: rect.minX, y: rect.midY))
        upperSquiggle.append(lowerSquiggle)
        return upperSquiggle
        
    }
    
    // Create a path for an oval shape within a rectangle.
    private func pathForOval(in rect: CGRect) -> UIBezierPath {
        let oval = UIBezierPath()
        let radius = rect.height / 2
        oval.addArc(withCenter: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                    radius: radius,
                    startAngle: CGFloat.pi / 2,
                    endAngle: CGFloat.pi * 3 / 2,
                    clockwise: true)
        oval.addLine(to: CGPoint(x: rect.minX + radius, y: rect.minY))
        oval.addArc(withCenter: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                    radius: radius,
                    startAngle: CGFloat.pi*3/2,
                    endAngle: CGFloat.pi/2,
                    clockwise: true)
        oval.close()
        return oval
    }
    
    
    //MARK: Nested Types
    
    // Enumeration for different fill types of symbols.
    private enum Fill: Int {
        case unfilled
        case striped
        case solid
    }
    
    // Enumeration for different symbol shapes.
    private enum Symbols: Int {
        case oval
        case squiggle
        case diamond
    }
    
    // Struct for defining colors used in the card.
    private struct Colors {
        static let red = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        static let green = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        static let purple = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        
        static let hint = #colorLiteral(red: 1, green: 0.5212053061, blue: 1, alpha: 1).cgColor
        static let selected = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1).cgColor
        static let matched = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1).cgColor
        static var missMatched = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
    }
    
    // Struct for defining aspect ratio values.
    private struct AspectRatio {
        static let faceFrame: CGFloat = 0.60
    }
    
    // Struct for defining size ratios.
    private struct SizeRatio {
        static let pinFontSizeToBoundsHeight: CGFloat = 0.09
        static let maxFaceSizeToBoundsSize: CGFloat = 0.75
        static let pipHeightToFaceHeight: CGFloat = 0.25
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        
    }
}

