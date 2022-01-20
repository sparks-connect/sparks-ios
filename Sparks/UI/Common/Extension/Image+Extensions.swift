//
//  Image+Extensions.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 17.01.22.
//  Copyright © 2022 AppWork. All rights reserved.
//


import UIKit

import AVFoundation
import CoreGraphics

extension UIImage {
    
    /**
     Creates an image with the specified color and size.
     I feel like this should be a convenience init but you can't set self from the `UIGraphicsGetImageFromCurrentImageContext()` call.
     
     - parameter color: The color of the image.
     - parameter size:  The size of the image.
     
     - returns: The UIImage with the color and size.
     */
    convenience init?(color: UIColor, size: CGSize) {
        if size.equalTo(.zero) {
            // Image size must be larger than 0x0.
            return nil
        }
        
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let cgImage = image?.cgImage {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }
    
    /**
     Takes the image and returns it with a tint color added.
     
     - parameter tintColor: The color to tint the image.
     
     - returns: The current image with a tint added.
     */
    func image(withTintColor tintColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: 0, y: self.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.setBlendMode(.normal)
            let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            if let cgiImage = self.cgImage {
                context.clip(to: rect, mask: cgiImage)
            }
            
            tintColor.setFill()
            
            context.fill(rect)
            
            if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                return newImage
            }
        }
        
        UIGraphicsEndImageContext()
        return nil
    }
    
    /// Updates the image to have the correct orientation.
    ///
    /// - Returns: Returns the image flipped properly.
    func normalizedImage() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height))
        if let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            UIGraphicsEndImageContext()
            return nil
        }
    }
    
    /// Creates an image in the tmp folder that is a JPEG.
    ///
    /// - Returns: The URL object that represents where that image is saved.
    func saveJPEGInTempFolder() -> URL? {
        if let normalizedImage = self.normalizedImage(), let imageData = normalizedImage.jpegData(compressionQuality: 1) {
            return imageData.saveInTempFolder(withExtension: "jpg")
        }
        return nil
    }
    
    /// Rotates an image the specified amount of degrees.
    ///
    /// - Parameter degree: The amount of degrees to rotate.
    /// - Returns: The image rotated the specified amount of degrees.
    final func rotate(byDegrees degree: Double) -> UIImage? {
        let radians = CGFloat(degree * .pi) / 180.0 as CGFloat
        
        let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: self.size))
        let t = CGAffineTransform(rotationAngle: radians)
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, scale)
        
        if let bitmap = UIGraphicsGetCurrentContext() {
            bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
            bitmap.rotate(by: radians)
            bitmap.scaleBy(x: 1.0, y: -1.0)
            
            if let cgImage = self.cgImage {
                bitmap.draw(cgImage, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
                if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
                    return newImage
                }
            }
        }
        return nil
        
    }
    
    /// Figures out the height of the image if it's width is constrained.
    ///
    /// - Parameter width: The width the image may be.
    /// - Returns: The height the image may be to fit the same aspect ratio.
    final func heightConstrained(toWidth width: CGFloat) -> CGFloat {
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude)
        let rect = AVMakeRect(aspectRatio: self.size, insideRect: boundingRect)
        return rect.size.height
    }
    
}
