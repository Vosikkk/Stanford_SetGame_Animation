//
//  Extension+Array.swift
//  SetGame
//
//  Created by Саша Восколович on 08.08.2023.
//

import Foundation
import UIKit


extension Array where Element: Equatable {
   
    // Helps us to understand double pressed button
   mutating func inOut(element: Element) {
        if let from = self.firstIndex(of: element) {
            self.remove(at: from)
        } else {
            self.append(element)
        }
    }
    
    // Remove all the same elements from array
    mutating func remove(elements: [Element]) {
        self = self.filter{ !elements.contains($0) }
    }
    
    
    // just replace "elements: [Element]" on "new: [Element]" in self.array ;)
    mutating func replace(elements: [Element], with new: [Element]) {
        guard elements.count == new.count else { return }
        for index in 0..<new.count {
            if let indexMatched = self.firstIndex(of: elements[index]) {
                self [indexMatched] = new[index]
            }
        }
    }
    
    // just return array which contains indexes of recieved array of elements
    func indices(of elements: [Element]) -> [Int] {
        guard self.count >= elements.count, elements.count > 0 else { return [] }
        return elements.map{ self.firstIndex(of: $0) }.compactMap{ $0 }
    }
}


extension String {
    
    // Repeat string n times and divide it by separator
    func join(n: Int, with separator: String) -> String {
        guard n > 1 else { return self }
        return Array(repeating: self, count: n).joined(separator: separator)
    }
}


extension Int {
    // increment
    func incrementCicle(in number: Int) -> Int {
        return (number - 1) > self ? self + 1 : 0
    }
    
    
    func random() -> Int {
            guard self > 0 else { return 0 }
            return Int.random(in: 0..<self)
        }
}

extension CGRect {
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
}
extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}

extension UIFont {
    
    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
    
}

extension CGFloat {
    var arc4random: CGFloat {
        return self * (CGFloat(UInt32.random(in: .min ... .max)) / CGFloat(UInt32.max))
    }
}
