
//
//  NewMessagePageViewController.swift
//  Sparks
//
//  Created by Nika Samadashvili on 6/8/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import SnapKit

class NewMessagePageViewController: BaseController, BasePageViewController {
    
    private var currentViewControllerIndex = 0
    
    let pageViewController: UIPageViewController = {
        let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        return controller
    }()
    
    var viewControllers : [PageBaseController] = [NewMessageController(), SearchingRadarController() ,MessageSentController()]
    
    
    private func header(at index: Int) -> String {
        return "Onboarding"
    }
    
    private var displaysBack: Bool {
        self.currentViewControllerIndex > 0
    }
    
    lazy private(set) var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Image.close.uiImage, for: .normal)
        button.addTarget(self, action: #selector(didTapAtCloseButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var editModeTitleLabel : UILabel = {
        let view = Label()
        view.font =  UIFont.systemFont(ofSize: 22, weight: .bold)
        view.textColor = .white
        view.text = "Profile Update"
        return view
    }()
    
    override func configure() {
        super.configure()
        
        self.addChild(pageViewController)
        self.view.addSubview(pageViewController.view)
        pageViewController.willMove(toParent: self)
        
        pageViewController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
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
    
    private func initCloseButton() {
        view.addSubview(closeButton)
        view.addSubview(editModeTitleLabel)
        closeButton.snp.makeConstraints({
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.right.equalToSuperview().inset(30)
            $0.height.equalTo(30)
            $0.width.equalTo(30)
        })
        closeButton.contentMode = .scaleAspectFill
        closeButton.layer.cornerRadius = 15
        closeButton.clipsToBounds = true
        
        editModeTitleLabel.snp.makeConstraints {
            $0.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
        }
    }
    
    @objc func didTapAtCloseButton() {
        dismiss(animated: true, completion: nil)
    }
}


extension NewMessagePageViewController: UIPageViewControllerDataSource {
    
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

