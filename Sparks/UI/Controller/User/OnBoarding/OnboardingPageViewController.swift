//
//  OnboardingPageViewController.swift
//  Sparks
//
//  Created by Nika Samadashvili on 6/8/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import SnapKit

class OnboardingPageViewController: BaseController, BasePageViewController {
    
    private var currentViewControllerIndex = 0
    
    private(set) lazy var progressView: ProgressView = {
        let view = ProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = Color.purple.uiColor
        return view
    }()
    
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var viewControllers : [UIViewController] = []
    
    var percent: CGFloat {
        return CGFloat(currentViewControllerIndex) / CGFloat(viewControllers.count)
    }
    
    private func header(at index: Int) -> String {
        return Consts.App.name
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
    
    private lazy var labelHeader : UILabel = {
        let view = Label()
        view.font =  UIFont.systemFont(ofSize: 22, weight: .bold)
        view.textColor = .white
        view.textAlignment = .center
        return view
    }()
    
    private lazy var buttonBack : UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "ic_back"), for: .normal)
        view.tintColor = .white
        view.addTarget(self, action: #selector(switchTabToPrevious), for: .touchUpInside)
        return view
    }()
    
    private func refresh() {
        self.progressView.percentage = self.percent
        self.labelHeader.text = self.header(at: self.currentViewControllerIndex)
        self.buttonBack.isHidden = !self.displaysBack
    }
    
    override func configure() {
        super.configure()
        
        self.view.addSubview(labelHeader)
        labelHeader.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            make.height.equalTo(44)
            make.width.equalToSuperview().multipliedBy(0.6)
        }
        
        self.view.addSubview(buttonBack)
        buttonBack.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(labelHeader)
            make.left.equalTo(8)
            make.width.equalTo(buttonBack.snp.height)
        }
        
        let controllers = self.setupScreens()
        controllers.forEach { (viewController) in
            viewController.pageViewController = self
        }
        
        self.viewControllers = controllers
        
        self.addChild(pageViewController)
        self.view.addSubview(pageViewController.view)
        pageViewController.willMove(toParent: self)
        
        pageViewController.view.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(labelHeader.snp.bottom).offset(8)
        }
        
        pageViewController.setViewControllers([viewControllers[0]], direction: .forward, animated: false, completion: nil)
       // pageViewController.dataSource = self
        self.refresh()
    }
    
    private func setupScreens() -> [PageBaseController] {
        
        guard let user = User.current else {
            return [ LoginController(), PhoneInputController(), SmsVerifyController() ]
        }
        
        var controllers: [PageBaseController] = []
        if user.isMissingName {
            controllers.append(NameInputController())
        }
        
        if user.isMissingGender {
            controllers.append(GenderController())
        }
        
        if user.isMissingBirthdate {
            controllers.append(BirthDateController())
        }
        
        if user.isMissingInterests {
            controllers.append(ProfileTagsController())
        }
        
        return controllers
    }
    
    func switchTabToNext(parameters: [String: Any]? = nil) {
        guard self.currentViewControllerIndex < self.viewControllers.count - 1 else {
            AppDelegate.updateRootViewController()
            return
        }
        self.currentViewControllerIndex += 1
        self.refresh()
        let controller = viewControllers[self.currentViewControllerIndex]
        (controller as? PageBaseController)?.parameters = parameters
        pageViewController.setViewControllers([controller],
                                              direction: .forward,
                                              animated: true,
                                              completion: nil)
    }
    
    @objc func switchTabToPrevious() {
        guard self.currentViewControllerIndex > 0 else { return }
        self.currentViewControllerIndex -= 1
        self.refresh()
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


extension OnboardingPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0, viewControllers.count > previousIndex else { return nil }
        
        return viewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = viewControllers.firstIndex(of: viewController) else {
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

