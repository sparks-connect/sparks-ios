//
//  FlexibleTextView.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 5/18/20.
//  Copyright © 2020 Sparks. All rights reserved.
//


import UIKit

/// Custom implementation of UITextView, to embed clickable links in texts without externally setting .attributedText property.
/// Resizes the text automatically based on it's bounds
class FlexibleTextView: UITextView {

    /// Example:
    /**
     .text = [
        ("Click the ", nil),
        ("link", URL("https://test.com")),
        (" below", nil)
     ]
     */
    /// It will display - "Click the link below",  where "link" will be highlighted and clicking on it will open the URL
    var texts = [(String, URL?)]()
    
    var fullText: String {
        var result = ""
        texts.forEach { (text, _) in
            result.append(text)
        }
        return result
    }
    
    /// Link is not clickable if UITextView is not editable, but this we need to be readonly.
    override var canBecomeFirstResponder: Bool {
        return false
    }
    
    /// Setting maxFontSize will set initial font size for the text, but it will be reduced based on the size
    var maxFontSize: CGFloat = 15
    
    private lazy var currentFontSize: CGFloat = maxFontSize
    
    lazy var textFont = UIFont.font(for: 15)
    lazy var urlFont = UIFont.font(for: 15, style: .bold)
    lazy var textPartColor = self.textColor ?? UIColor.darkText
    lazy var urlPartColor = self.textColor ?? UIColor.darkText
    
    /// If set, distance between lines will be adjusted accordingly
    var lineHeight: CGFloat?
    
    /// Text alignment
    var alignment: NSTextAlignment?
    
    private func recalculateFontSize() {
        currentFontSize = maxFontSize
        update()
    }
    
    private func update() {
        
        guard !texts.isEmpty else { return }
        
        let mutableAttributes = NSMutableAttributedString(string: fullText)
        
        var currentLocation: Int = 0
        var currentLength: Int = 0
        
        self.linkTextAttributes = [ .foregroundColor: self.urlPartColor, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue ]
        
        for (text, url) in texts {
            
            currentLength = text.count
            
            let range = NSRange(location: currentLocation, length: currentLength)
            let isUrl = url != nil
            
            let font = isUrl ? self.urlFont : self.textFont
            let size = isUrl ? currentFontSize + 1 : currentFontSize
            let resizedFont = UIFont(descriptor: font.fontDescriptor, size: size)
            
            if let url = url {
                mutableAttributes.addAttributes([.font: resizedFont, .link: url], range: range)
            } else {
                let attirbutes:[NSAttributedString.Key: Any] = [.foregroundColor: self.textPartColor, .font: resizedFont]
                mutableAttributes.addAttributes(attirbutes, range: range)
            }
            
            currentLocation += currentLength
        }
        
        let style = NSMutableParagraphStyle()
        
        if let height = self.lineHeight { style.lineSpacing = height }
        if let alignment = self.alignment { style.alignment = alignment }
        
        mutableAttributes.addAttributes([.paragraphStyle: style], range: NSRange(location: 0, length: fullText.count))
        self.attributedText = mutableAttributes
        
        if self.contentSize.height > self.frame.size.height {
            currentFontSize -= 0.25
            self.update()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        recalculateFontSize()
    }
}
