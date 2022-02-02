
//
//  BottomSheetController.swift
//  Sparks
//
//  Created by Nika Samadashvili on 3/20/20.
//  Copyright © 2020 Sparks. All rights reserved.
//


import UIKit
import UIKit.UIGestureRecognizerSubclass

private enum State {
    case closed
    case open
}

extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}


// override popupViewHeight to change up popup height
// add subviews to popupView to keep it cool

class BottomSheetController: BaseController {
    
    struct BottomSheetProps {
        static let animationDuration: Double = 0.35
        static let overlayOpenAlpha: CGFloat = 0.6
        static let overlayClosedAlpha: CGFloat = 0
        //TODO: move all possible values here...
    }
    
    //MARK: Properties
    
    var popupViewHeight: CGFloat {
        return 500
    }
    private var currentState: State = .closed
    private var runningAnimators = [UIViewPropertyAnimator]()
    private var animationProgress = [CGFloat]()
    private var bottomConstraint = NSLayoutConstraint()
    
    private lazy var panRecognizer: InstantPanGestureRecognizer = {
        let recognizer = InstantPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = BottomSheetProps.overlayClosedAlpha
        return view
    }()
    
    lazy var popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    lazy var draggerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false
        return view
    }()
    
    lazy var draggerPanView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        return view
    }()
    
    //MARK: Life cycle
    
    override func configure() {
        super.configure()
        layout()
        popupView.addGestureRecognizer(panRecognizer)
    }
    
    override func didAppear() {
        animateTransitionIfNeeded(to: currentState.opposite, duration: BottomSheetProps.animationDuration)
    }
    
    //MARK: methods
    
    func setTintColor(color:UIColor){
        self.draggerPanView.backgroundColor = color
        self.popupView.backgroundColor      = color
    }
    
    func closePopupView(){
        animateTransitionIfNeeded(to: .closed, duration: BottomSheetProps.animationDuration)
    }
    
    //MARK: Private methods
    
    private func layout() {
        view.backgroundColor = .clear
        view.addSubview(overlayView)
        
        overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        overlayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(popupView)
        
        popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: popupViewHeight)
        bottomConstraint.isActive = true
        popupView.heightAnchor.constraint(equalToConstant: popupViewHeight).isActive = true
        
        view.addSubview(draggerView)
        draggerView.addSubview(draggerPanView)
        
        draggerPanView.snp.makeConstraints({
            $0.bottom.equalTo(draggerView.snp.bottom).inset(8)
            $0.centerX.equalTo(draggerView.snp.centerX)
            $0.width.equalTo(50)
            $0.height.equalTo(4)
        })
        
        draggerView.snp.makeConstraints({
            $0.top.equalTo(popupView.snp.top).inset(-32)
            $0.centerX.equalTo(popupView.snp.centerX)
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(32)
        })
                
    }
    
    private func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {
        
        guard runningAnimators.isEmpty else { return }
        
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
            case .open:
                self.bottomConstraint.constant = 0
                self.popupView.layer.cornerRadius = 20
                self.overlayView.alpha = BottomSheetProps.overlayOpenAlpha
            case .closed:
                self.bottomConstraint.constant = self.popupViewHeight
                self.popupView.layer.cornerRadius = 0
            }
            self.view.layoutIfNeeded()
        })
        
        transitionAnimator.addCompletion { position in
            
            switch position {
            case .start:
                self.currentState = state.opposite
            case .end:
                self.currentState = state
            default:
                ()
            }
            
            switch self.currentState {
            case .open:
                self.bottomConstraint.constant = 0
            case .closed:
                self.bottomConstraint.constant = self.popupViewHeight
                self.dismiss(animated: false, completion: nil)
            }
            self.runningAnimators.removeAll()
        }
        transitionAnimator.startAnimation()
        runningAnimators.append(transitionAnimator)
    }
    
//MARK: @objc methods
    
    @objc func popupViewPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            animateTransitionIfNeeded(to: currentState.opposite, duration: BottomSheetProps.animationDuration)
            runningAnimators.forEach { $0.pauseAnimation() }
            animationProgress = runningAnimators.map { $0.fractionComplete }
        case .changed:
            let translation = recognizer.translation(in: popupView)
            var fraction = -translation.y / popupViewHeight
            if currentState == .open { fraction *= -1 }
            
            for (index, animator) in runningAnimators.enumerated() {
                animator.fractionComplete = fraction + animationProgress[index]
            }
            
            let maxAlpha: CGFloat = BottomSheetProps.overlayOpenAlpha
            var resultAlpha = maxAlpha
            if translation.y >= 0 {
                resultAlpha = (maxAlpha - translation.y / popupViewHeight)
            }
            overlayView.alpha = resultAlpha
            //TODO: Needs more smoothness & Velocity checking...
            
        case .ended:
            let yVelocity = recognizer.velocity(in: popupView).y
            let shouldClose = yVelocity > 0
            switch currentState {
            case .open:
                if !shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            case .closed:
                if shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if !shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            }
            runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
        default:
            ()
        }
    }
}

/// A pan gesture that enters into the `began` state on touch down instead of waiting for a touches moved event.
class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    //TODO: this was blocking subiews to receive a touch
    //Fix this and then uncomment please
    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if (self.state == UIGestureRecognizer.State.began) { return }
        super.touchesBegan(touches, with: event)
        self.state = UIGestureRecognizer.State.began
    }*/
}

extension UIPanGestureRecognizer {

    enum GestureDirection {
        case Up
        case Down
        case Left
        case Right
    }

    /// Get current vertical direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func verticalDirection(target: UIView) -> GestureDirection {
        return self.velocity(in: target).y > 0 ? .Down : .Up
    }

    /// Get current horizontal direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func horizontalDirection(target: UIView) -> GestureDirection {
        return self.velocity(in: target).x > 0 ? .Right : .Left
    }

    /// Get a tuple for current horizontal/vertical direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func versus(target: UIView) -> (horizontal: GestureDirection, vertical: GestureDirection) {
        return (self.horizontalDirection(target: target), self.verticalDirection(target: target))
    }

}
