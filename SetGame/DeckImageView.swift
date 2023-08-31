//
//  DeckImageView.swift
//  SetGame
//
//  Created by Саша Восколович on 23.08.2023.
//

import UIKit

class DeckImageView: UIImageView {

  
    var deckCount: String = "81" {
        didSet { setNeedsDisplay(); setNeedsLayout() }
    }
    
    private var deckCountString: NSAttributedString {
        return centeredAttrubitedString(deckCount, fontSize: labelFontSize)
    }
    
    private var labelFontSize: CGFloat {
        if UIScreen.main.traitCollection.verticalSizeClass == .regular && UIScreen.main.traitCollection.horizontalSizeClass == .regular {
            return bounds.size.height * 0.5
        }
        return bounds.size.height * 0.3
    }
    
    private lazy var deckCountLabel = createLabel()
    
    
    override func draw(_ rect: CGRect) {
        if let cardBackImage = UIImage(named: "Deal Deck", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
            cardBackImage.draw(in: bounds)
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureLabel(deckCountLabel)
        deckCountLabel.center = bounds.origin.offsetBy(dx: bounds.size.width / 2, dy: bounds.size.height / 2)
        
    }
    
    private func configureLabel(_ label: UILabel) {
        label.attributedText = deckCountString
        label.frame.size = CGSize.zero
        label.sizeToFit()
    }
    
    
    private func createLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .white
        addSubview(label)
        return label
    }
    
    private func centeredAttrubitedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize).bold()
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle: paragraphStyle,
                                                               .font: font])
    }

}

