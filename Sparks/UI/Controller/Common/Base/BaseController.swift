//
//  BaseController.swift
//  cario
//
//  Created by Irakli Vashakidze on 3/31/19.
//  Copyright © 2019 Cario. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class BaseController : UIViewController, BasePresenterView {
    
    private(set) var tintColor = Color.primary.uiColor
    
    func getPresenter() -> Presenter {
        return BasePresenter<BaseView>()
    }
    
    // MARK: ====== Lifecycle ====================================
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Color.background.uiColor
        self.customInit()
        self.getPresenter().attach(this: self)
        self.configureNavigationBar()
        self.configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getPresenter().willAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.didAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.getPresenter().willDisappear()
    }    
    
    func customInit() {} // Custom presenter initializer
    func configure() {} // Override in subclasses
    func willAppear() {} // Override in subclasses
    func willDisappear() {}
    func didAppear() {} // Override in subclasses
    // MARK: ====== Navigation bar ===============================
    
    func configureNavigationBar() {
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = Color.background.uiColor
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        //self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.rightBarButtonItems = self.rightBarButtons()
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItems = self.leftBarButtonItems()
    }
    
    func rightBarButtons() -> [UIBarButtonItem] {
        if !self.getPresenter().isLoggedIn() { return [] }
        
        return []
    }
    
    func leftBarButtonItems() -> [UIBarButtonItem] {
        if !self.getPresenter().isLoggedIn() { return [] }
        
        let imageView = UIImageView(image: #imageLiteral(resourceName: "ic_launchscreen"))
        imageView.contentMode = .scaleAspectFit
        let appIcon = UIBarButtonItem(customView: imageView)
        appIcon.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        appIcon.customView?.translatesAutoresizingMaskIntoConstraints = false
        appIcon.customView?.heightAnchor.constraint(equalToConstant: 40).isActive = true
        appIcon.customView?.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -24;
        
        return [negativeSpacer]
    }
    
    // MARK: ====== Other ====================================
    
    func showImagePicker(delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate,
                         otherActions: [UIAlertAction]? = nil,
                         from view: UIView) {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = delegate
        imagePicker.allowsEditing = false
        
        var actions = [UIAlertAction]()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let takePhotoAction = UIAlertAction(title: "Take photo",
                                                style: .default,
                                                handler: {
                                                    (alert: UIAlertAction!) -> Void in
                                                    imagePicker.sourceType = .camera
                                                    self.present(imagePicker, animated: true, completion: nil)
            })
            
            actions.append(takePhotoAction)
        }
        
        
        let chooseFromGalleryAction = UIAlertAction(title: "Choose from gallery",
                                                    style: .default,
                                                    handler: { (alert: UIAlertAction!) -> Void in
                                                        self.openGallery(delegate: delegate)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        actions.append(contentsOf: [chooseFromGalleryAction, cancelAction])
        
        if let _otherActions = otherActions {
            actions.append(contentsOf: _otherActions)
        }
        
        self.showActionSheetWith(actions: actions, in: view)
    }
    
    
    func showActionSheetWith(actions: [UIAlertAction], in view: UIView) {
        if actions.count > 0 {
            main {
                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
                actions.forEach({ actionSheet.addAction($0) })
                
                actionSheet.popoverPresentationController?.sourceRect = view.frame
                actionSheet.popoverPresentationController?.sourceView = self.view
                
                self.present(actionSheet, animated: true, completion: nil)
            }
        }
    }
    
    func openGallery(delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = delegate
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func notifyError(message: String, okAction: (() -> Void)? = nil) {
        //Ref - https://github.com/Daltron/NotificationBanner
        let banner = GrowingNotificationBanner(title: "", subtitle: message, style: .warning)
        banner.show()
//        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
//        let action = UIAlertAction(title: "Ok", style: .default, handler: {(action) in
//            okAction?()
//        })
//        alert.addAction(action)
//        self.present(alert, animated: true, completion: nil)
    }
    
    func reloadView() {} // Override in subclasses
 
    deinit {
        self.getPresenter().detach()
    }
}

