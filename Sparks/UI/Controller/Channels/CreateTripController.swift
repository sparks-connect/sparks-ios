//
//  CreateTripVC.swift
//  Sparks
//
//  Created by Adroit Jimmy on 26/01/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

class CreateTripController: BottomSheetController, BasePageViewController {
    
    private var currentViewControllerIndex = 0
    
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

    var viewControllers : [PageBaseController] = [TripNameInputController(), TripDateController() , TripBaseController(), TripBaseController()]
    
    private lazy var titeLabel: Label = {
        let lbl = Label()
        lbl.textAlignment = .center
        lbl.font =  UIFont.systemFont(ofSize: 18, weight:.bold)
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.textColor = .white
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.5
        lbl.text = "New Trip"
        return lbl
    }()
    
    override var popupViewHeight: CGFloat {
        return 380//UIScreen.main.bounds.height - UIScreen.main.bounds.height / 5.8
    }
    
    
    override func configure() {
        super.configure()
        
        self.popupView.backgroundColor = Color.background.uiColor
        self.popupView.addSubview(titeLabel)
        titeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }
        
        self.addChild(pageViewController)
        self.popupView.addSubview(pageViewController.view)
        pageViewController.willMove(toParent: self)
        
        pageViewController.view.snp.makeConstraints { (make) in
            make.top.equalTo(titeLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        pageViewController.setViewControllers([viewControllers[0]], direction: .forward, animated: false, completion: nil)
        pageViewController.dataSource = self
        
        for view in self.pageViewController.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = false
            }
        }
        
        viewControllers.forEach { (viewController) in
            viewController.pageViewController = self
        }
    }
    
    override func didAppear() {
        super.didAppear()
    }
    
    override func reloadView() {
        super.reloadView()
    }
    
    func switchTabToNext(parameters: [String: Any]? = nil) {
        guard self.currentViewControllerIndex < self.viewControllers.count - 1 else { return }
        self.currentViewControllerIndex += 1
        let controller = viewControllers[self.currentViewControllerIndex]
        controller.parameters = parameters
        pageViewController.setViewControllers([controller],
                                              direction: .forward,
                                              animated: true,
                                              completion: nil)
    }
    
    @objc func switchTabToPrevious() {
        guard self.currentViewControllerIndex > 0 else { return }
        self.currentViewControllerIndex -= 1
        let controller = viewControllers[self.currentViewControllerIndex]
        pageViewController.setViewControllers([controller],
                                              direction: .reverse,
                                              animated: true,
                                              completion: nil)
    }
    
    func didTapAtCloseButton() {
        dismiss(animated: true, completion: nil)
    }
}

extension CreateTripController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = viewControllers.firstIndex(of: viewController as! PageBaseController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0, viewControllers.count > previousIndex else { return nil }
        
        return viewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = viewControllers.firstIndex(of: viewController as! PageBaseController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = viewControllers.count
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return viewControllers[nextIndex]
    }
    
}

