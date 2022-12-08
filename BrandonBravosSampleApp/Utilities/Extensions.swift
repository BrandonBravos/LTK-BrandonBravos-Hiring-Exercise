//
//  extensions.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/6/22.
//

import Foundation
import UIKit
import AVFoundation

extension UIImage{
    
    /// resizes an image and reduces cpu costs
    func resizeImage(toSize size: CGSize)-> UIImage{
            let maxSize = size

            let availableRect = AVFoundation.AVMakeRect(aspectRatio: self.size, insideRect: .init(origin: .zero, size: maxSize))
            let targetSize = availableRect.size

            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

            let resized = renderer.image { (context) in
                self.draw(in: CGRect(origin: .zero, size: targetSize))
            }
            
                return resized
    }
    
    /// checks an images width, and our desired width to return a height with the same aspect ratio.
    func getHeightAspectRatio(withWidth:CGFloat ) -> CGFloat{
        let imageHeight = self.size.height
        let imageWidth = self.size.width
        let ratio = imageHeight / imageWidth

        let desiredWidth = withWidth
        let newHeight = desiredWidth * ratio
        
        return newHeight
    }
}



extension UIFont{
    enum MontserratType: String{
        case light = "Montserrat-Light"
        case medium = "Montserrat-Medium"
        case regular = "Montserrat-Regular"
        case bold = "Montserrat-SemiBold"
    }
    
    /// set the font to montserrat [light, mrdium, regular, bold] with corresponding size
    static func montserratFont(withMontserrat fontType: MontserratType, withSize size: CGFloat)-> UIFont {
        return UIFont(name: fontType.rawValue, size: size)!
    }
}

extension String {
    var capitalizedSentence: String {
        let firstLetter = self.prefix(1).capitalized
        let remainingLetters = self.dropFirst().lowercased()
        return firstLetter + remainingLetters
    }

}
