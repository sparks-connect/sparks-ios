//
//  View.swift
//  BehaviorPro
//
//  Created by Irakli Vashakidze on 1/29/19.
//  Copyright © 2019 BehaviorPro. All rights reserved.
//

import UIKit

extension UIView {
    
    func clearSubviews() {
        self.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
    }
    
    func centeredScaledFrame(by factor: CGFloat, considerOrigin: Bool = false) -> CGRect {
        return centeredScaledFrame(relatedTo: self, by: factor, considerOrigin: considerOrigin)
    }
    
    func centeredScaledFrame(relatedTo view: UIView, by factor: CGFloat, considerOrigin: Bool = false) -> CGRect {
        var rect = CGRect.zero
        let size = view.frame.size
        let scaledW = size.width * factor
        let scaledH = size.height * factor
        rect.origin.x = (considerOrigin ? view.frame.origin.x : 0) + (size.width - scaledW) / 2
        rect.origin.y = (considerOrigin ? view.frame.origin.y : 0) + (size.height - scaledH) / 2
        rect.size.width = scaledW
        rect.size.height = scaledH
        return rect
    }
    
    func setVisible(_ visible: Bool) {
        self.isHidden = !visible
    }
    
    func addTapGesture(target: Any?, selector: Selector) {
        self.addGestureRecognizer(UITapGestureRecognizer(target: target, action: selector))
    }
    
    func addToContainer(view: UIView, attachToBottom: Bool = true, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        
        topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top).isActive = true
        leftAnchor.constraint(equalTo: view.leftAnchor, constant: insets.left).isActive = true
        rightAnchor.constraint(equalTo: view.rightAnchor, constant: -insets.right).isActive = true
        
        if attachToBottom {
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom).isActive = true
        }
    }
    
    @IBInspectable var cRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor ?? UIColor.gray.cgColor)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
}


extension UIView {
    func addAllSideShadow(with radius: CGFloat, color: UIColor) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = radius
    }
    
    func addRightShadow(with radius: CGFloat, width: CGFloat, color: UIColor) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize(width: width, height: width)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = radius
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    func rotate(angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat.pi
        let rotation = self.transform.rotated(by: radians)
        self.transform = rotation
    }
    
    func shake(duration: CFTimeInterval, forKey key: String) {
        let translation = CAKeyframeAnimation(keyPath: "transform.translation.x");
        translation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        translation.values = [-5, 5, -5, 5, -3, 3, -2, 2, 0]
        
        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotation.values = [-5, 5, -5, 5, -3, 3, -2, 2, 0].map {
            ( degrees: Double) -> Double in
            let radians: Double = (Double.pi * degrees) / 180.0
            return radians
        }
        
        let shakeGroup: CAAnimationGroup = CAAnimationGroup()
        shakeGroup.animations = [translation, rotation]
        shakeGroup.duration = duration
        shakeGroup.repeatCount = .infinity
        self.layer.add(shakeGroup, forKey: key)
    }
    
    func addSubviewWithConstrainedBounds(subview: UIView, inset: UIEdgeInsets? = nil) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(subview)
        
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset?.left ?? 0),
            subview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -(inset?.right ?? 0)),
            subview.topAnchor.constraint(equalTo: self.topAnchor, constant: inset?.top ?? 0),
            subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -(inset?.bottom ?? 0))
        ])
    }
}

extension UITableView {
    func register(_ nibIdentifier: String, forCellReuseIdentifier identifier: String) {
        self.register(UINib(nibName: nibIdentifier, bundle: nil), forCellReuseIdentifier: identifier)
    }
}

class BaseView : UIView {
    
    init() {
        super.init(frame: CGRect.zero)
        self._configure()
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._configure()
        self.configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self._configure()
        self.configure()
    }
    
    fileprivate func _configure() {
        
    }
    
    func configure() {
        
    }
    
}

class NibView : BaseView {
    
    var nibIdentifier: String? {
        return String(describing: type(of: self))
    }
    
    @IBOutlet var contentView:UIView!
    
    override func _configure() {
        if let identifier = self.nibIdentifier {
            Bundle.main.loadNibNamed(identifier, owner: self, options: nil)
            guard let content = contentView else { return }
            self.addSubview(content)
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[c]|",
                                                               options: [],
                                                               metrics: nil,
                                                               views: ["c":content]))
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[c]|",
                                                               options: [],
                                                               metrics: nil,
                                                               views: ["c":content]))
            content.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}

class CircleCornerView : UIView {
    
    init() {
        super.init(frame: CGRect.zero)
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    func configure() {
        // Override in subclasses
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.size.height / 2
    }
}

