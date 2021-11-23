//
//  ImageView.swift
//  BehaviorPro
//
//  Created by Irakli Vashakidze on 2/11/19.
//  Copyright © 2019 BehaviorPro. All rights reserved.
//

import UIKit
import SDWebImage

class ImageView : UIImageView {
    
    private(set) var url: URL?
    private let context = CIContext(options: nil)
    private var originalImage: UIImage?
    
    init() {
        super.init(frame: CGRect.zero)
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        self.configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    func configure() {
        self.clipsToBounds  = true
        self.contentMode    = .scaleAspectFill
    }
    
    func setDefaultImage(_ image: UIImage?) {
        self.image = image
    }
    
    func blurEffect(_ radius: Double = 10) {
        guard let image = self.image,
                let currentFilter = CIFilter(name: "CIGaussianBlur"),
                    let cropFilter = CIFilter(name: "CICrop") else { return }
        
        let beginImage = CIImage(image: image)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter.setValue(radius, forKey: kCIInputRadiusKey)

        cropFilter.setValue(currentFilter.outputImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")

        guard let output = cropFilter.outputImage,
              let cgimg = context.createCGImage(output, from: output.extent) else { return }
        
        self.originalImage = image
        
        let processedImage = UIImage(cgImage: cgimg)
        self.image = processedImage
    }
    
    func removeBlur() {
        if let image = originalImage {
            self.image = image
        }
    }
    
    func setImageFromUrl(_ url: String?, placeholderImg : UIImage? = nil, completion:((_ image: UIImage?, _ error: Error?)->Void)?=nil) {
        
        if let _url = url, !_url.isEmpty {
            if let __url = URL(string: _url) {
                self.url = __url
                self.sd_setImage(with: __url,
                                 placeholderImage: placeholderImg,
                                 options: .queryDiskDataSync, progress: nil) { (img, err, type, url) in
                    if err == nil {
                        self.contentMode = .scaleAspectFill
                    }
                    completion?(img, err)
                }
            } else {
                self.url = nil
                self.image = placeholderImg
                self.contentMode = .scaleAspectFit
                completion?(nil, CIError.invalidContent)
            }
        } else {
            self.url = nil
            self.image = placeholderImg
            self.contentMode = .scaleAspectFit
            completion?(placeholderImg, CIError.invalidContent)
        }
    }
}

class CircleImageView: ImageView {    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.size.height / 2
    }
}

class BPCircleIconImageView : UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.size.height / 2
    }
}

class DashedImageView : ImageView {
    private let shapeLayer = CAShapeLayer()
    
    override var tintColor: UIColor! {
        didSet {
            shapeLayer.strokeColor = self.tintColor.cgColor
        }
    }
    
    override func configure() {
        super.configure()
        shapeLayer.fillColor = nil;
        shapeLayer.lineWidth = 8
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [16, 8]
        
        self.layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        let rect = self.bounds
        shapeLayer.frame = rect
        shapeLayer.path = UIBezierPath(rect: rect).cgPath
        shapeLayer.position = CGPoint(x: rect.size.width/2, y: rect.size.height/2)
    }
}
