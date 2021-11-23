//
//  Spinner.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 4/14/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

fileprivate func deg2rad(_ degree: CGFloat) -> CGFloat {
    return degree * CGFloat(Float.pi) / 180
}

class SpinnerBoard: UIView {
    private(set) lazy var numbers = [Int]()
    private var color1 = Color.purple.uiColor
    private var color2 = color(from: "F29FBD")
    
    private lazy var labels = [Label]()
    
    var angle: CGFloat {
        CGFloat(360 / numbers.count)
    }
    
    init(numbers: [Int], color1: UIColor = Color.purple.uiColor, color2: UIColor = color(from: "F29FBD")) {
        super.init(frame: CGRect.zero)
        self.clipsToBounds = true
        self.numbers = numbers
        
        numbers.forEach { (number) in
            let label = createLabel(number: number)
            self.addSubview(label)
            labels.append(label)
        }
        
        self.color1 = color1
        self.color2 = color2
    }
    
    private func createLabel(number: Int) -> Label {
        let label = Label()
        label.text = "\(number)"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        for i in 0..<numbers.count {
            self.createTriangle(index:i, number: numbers[i])
        }
    }
    
    private func createTriangle(index: Int, number: Int) {
        let path = UIBezierPath()
        
        let w = self.frame.size.width
        let h = self.frame.size.height
        
        let side_w = 2 * ((h / 2) * abs(tan(deg2rad(angle/2))))
        path.move(to: CGPoint(x: w/2, y: h/2))
        path.addLine(to: CGPoint(x: (w - side_w)/2, y: 0))
        path.addLine(to: CGPoint(x: w - ((w - side_w)/2), y: 0))
        path.close()
        
        if index % 2 == 0 {
            color2.setFill()
        } else {
            color1.setFill()
        }
    
        rotate(path: path, radians: deg2rad(angle * CGFloat(index)))
        
        path.fill()
    }
    
    private func rotate(path: UIBezierPath, radians: CGFloat) {
        
        let center = CGPoint(x: bounds.maxX / 2, y: bounds.maxY / 2)
        
        path.apply(CGAffineTransform(translationX: -center.x, y: -center.y))

        // Rotate
        path.apply(CGAffineTransform(rotationAngle: radians))

        // Move origin back to original location
        path.apply(CGAffineTransform(translationX: center.x, y: center.y))
    }
    
    private func rotate(view: UIView, radians: CGFloat, anchorY: CGFloat = 1) {
        view.layer.anchorPoint = CGPoint(x: 0.5, y: anchorY)
        var transform = CATransform3DMakeRotation(radians, 0, 0, 1.0);
        transform.m34 = 0.0015
        view.layer.transform = transform
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = bounds.size.height / 2
        
        let w = self.frame.size.width
        let h = self.frame.size.height
        
        let side_w: CGFloat = 60
        
        self.labels.forEach { (view) in
            view.frame = CGRect(x: (w - side_w)/2, y: 0, width: side_w, height: h/2)
        }
        
        for (index, view) in self.labels.enumerated() {
            self.rotate(view: view, radians: deg2rad(CGFloat(index) * angle))
        }
    }
}

class Spinner: UIControl {
    
    private var board: SpinnerBoard!
    private lazy var spinnerArrow = UIImageView(image: #imageLiteral(resourceName: "ic_droplet"))
    private(set) var selectedNumber = 0
    
    init(numbers: [Int], color1: UIColor = Color.purple.uiColor, color2: UIColor = color(from: "F29FBD")) {
        super.init(frame: CGRect.zero)
        self.clipsToBounds = true
        self.board = SpinnerBoard(numbers: numbers, color1: color1, color2: color2)
        self.addSubview(self.board)
        self.spinnerArrow.tintColor = .white
        self.spinnerArrow.contentMode = .scaleAspectFit
        self.addSubview(spinnerArrow)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func spin() {
        guard !self.board.numbers.isEmpty else { return }
        let index = Int.random(in: 0...self.board.numbers.count - 1)
        self.selectedNumber = self.board.numbers[index]
        self.rotateAnimation(view: self.board, toIndex: index)
    }
    
    private func rotateAnimation(view: UIView, duration: CFTimeInterval = 4, toIndex: Int = 0) {
        
        let degree: CGFloat = 10 * 360 + self.board.angle
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = deg2rad(degree)
        rotateAnimation.duration = duration
        rotateAnimation.isAdditive = true
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.fillMode = .forwards
        rotateAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        view.layer.add(rotateAnimation, forKey: nil)
    }
    
    private func rotate(view: UIView, radians: CGFloat, anchorY: CGFloat = 1) {
        view.layer.anchorPoint = CGPoint(x: 0.5, y: anchorY)
        var transform = CATransform3DMakeRotation(radians, 0, 0, 1.0);
        transform.m34 = 0.0015
        view.layer.transform = transform
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = self.frame.size.width
        let h = self.frame.size.height
        let arrowW: CGFloat = w * 0.18
        self.board.frame = CGRect(x: 0, y: 0, width: w, height: h)
        self.spinnerArrow.frame = CGRect(x: (w - arrowW)/2, y: (h - arrowW)/2, width: arrowW, height: arrowW)
    }
}
