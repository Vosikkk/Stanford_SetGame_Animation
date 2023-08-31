//
//  BorderButton.swift
//  SetGame
//
//  Created by Саша Восколович on 06.08.2023.
//

import UIKit


class BorderButton: UIButton {
    
       // MARK: Default values related to the border of our button
        @IBInspectable var borderColor: UIColor = DefaultValues.borderColor {
            didSet {
                // Managed layer around of view
                layer.borderColor = borderColor.cgColor
            }
        }
        
        @IBInspectable var borderWidth: CGFloat = DefaultValues.borderWidth {
            didSet {
                layer.borderWidth = borderWidth
            }
        }
        
        @IBInspectable var cornerRadius: CGFloat = DefaultValues.cornerRadius {
            didSet {
                layer.cornerRadius = cornerRadius
            }
        }
        
    
     // MARK: Computed Property
    // Here we we managed active/not active our buttons such as Deal & Hint
     var disable: Bool {
            get {
                return !isEnabled
            }
            set {
                if newValue {
                    // Button not active
                    isEnabled = false
                    borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                } else {
                    // Button active, take standart border
                    isEnabled = true
                    borderColor = DefaultValues.borderColor
                }
            }
        }
     
     // MARK: Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            configure()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            configure()
        }
        
       
     
    // Configure default border for button
     private func configure () {
            layer.cornerRadius = cornerRadius
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = borderWidth
            clipsToBounds = true
        }
        
        // Constants
        private struct DefaultValues {
            static let cornerRadius: CGFloat = 8.0
            static let borderWidth: CGFloat = 4.0
            static let borderColor: UIColor = #colorLiteral(red: 0.5563425422, green: 0.9793455005, blue: 0, alpha: 1)
        }
}
