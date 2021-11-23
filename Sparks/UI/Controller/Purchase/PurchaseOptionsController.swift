//
//  PurchaseOptionsController.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 29.07.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseOptionsController: BaseController {
    
    private static let CONTAINER_H = 400
    private var products: [SKProduct] = []
    
    private(set) lazy var lblTitle: Label = {
        let view = Label()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .white
        view.textAlignment = .center
        view.font = UIFont.font(for: 26, style: .bold)
        view.text = "You are out of Sparks !"
        return view
    }()
    
    private(set) lazy var lblDesc: Label = {
        let view = Label()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = Color.lightGray.uiColor
        view.numberOfLines = 0
        view.minimumScaleFactor = 0.7
        view.lineBreakMode = .byTruncatingTail
        view.textAlignment = .center
        view.font = UIFont.font(for: 14, style: .regular)
        view.text = "Select 1 of these 2 options to get unlimited spark messages. You can cancel this subscription anytime."
        return view
    }()
    
    private(set) lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.background.uiColor
        return view
    }()
    
    private lazy var btnClose: UIButton = {
        let view = UIButton()
        view.setImage(#imageLiteral(resourceName: "ic_close"), for: .normal)
        view.addTarget(self, action: #selector(closeClicked(sender:)), for: .touchUpInside)
        return view
    }()
    
    
    override func configure() {
        super.configure()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.layout()
        self.setupPurchase()
    }
    
    private func setupPurchase() {
        SparkProductsManager.store.requestProducts { [weak self] success, products in
            guard let self = self else { return }
            guard let products = products, success else {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Failed to load list of products",
                                                            message: "Check logs for details",
                                                            preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            self.products = products
            main {
                self.addPurchaseOptions()
            }
        }
        
        // TODO: Revisit this place for restore
//        if SparkProductsManager.store.isProductPurchased(SparkProductsManager.sparksAnnualSubscription){
//            lblProductStatus.textColor = .green
//            lblProductStatus.text = "You already purchased annual item"
//        } else {
//            lblProductStatus.textColor = .red
//            lblProductStatus.text = "You dont have an item.\nPress purchase to buy or restore it"
//        }
    }
    
    private func purchaseItemIndex(index: Int) {
        SparkProductsManager.store.buyProduct(products[index]) { success, productId in
            guard success else {
                return
            }
        }
    }
    
    override func didAppear() {
        super.didAppear()
        self.containerView.snp.remakeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(PurchaseOptionsController.CONTAINER_H)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func layout() {
        
        self.view.addSubview(self.containerView)
        self.containerView.addSubview(btnClose)
        self.containerView.addSubview(lblTitle)
        self.containerView.addSubview(lblDesc)
        
        btnClose.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.right.equalTo(-8)
            make.size.equalTo(40)
        }
        
        lblTitle.snp.makeConstraints { make in
            make.top.equalTo(btnClose.snp.bottom).offset(16)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(40)
        }
        
        lblDesc.snp.makeConstraints { make in
            make.top.equalTo(lblTitle.snp.bottom).offset(16)
            make.left.equalTo(32)
            make.right.equalTo(-32)
            make.height.equalTo(48)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(PurchaseOptionsController.CONTAINER_H)
        }
    }
    
    private func addPurchaseOptions() {
        
        for i in 0..<self.products.count {
            let product = self.products[i]
            let view = PrimaryButton()
            view.setTitle("\(product.localizedTitle) (\(product.price) USD)", for: .normal)
            view.addTarget(self, action: #selector(purchaseClicked(sender:)), for: .touchUpInside)
            view.tag = i
            self.containerView.addSubview(view)
            
            let prevView = self.containerView.subviews[self.containerView.subviews.count - 2]
            view.snp.makeConstraints { make in
                make.top.equalTo(prevView.snp.bottom).offset(16)
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(64)
            }
        }
        
    }
    
    @objc private func purchaseClicked(sender: PrimaryButton) {
        self.purchaseItemIndex(index: sender.tag)
    }
    
    @objc private func closeClicked(sender: AnyObject) {
        
        self.containerView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(PurchaseOptionsController.CONTAINER_H)
        }
        
        UIView.animate(withDuration: 0.25) {
            let timingFunction = CAMediaTimingFunction.init(controlPoints: 0.25, 0.85, 0.55, 1)
            CATransaction.begin()
            CATransaction.setAnimationTimingFunction(timingFunction)
            self.view.layoutIfNeeded()
            CATransaction.commit()
        } completion: { finished in
            self.dismiss(animated: false, completion: nil)
        }
    }
}
