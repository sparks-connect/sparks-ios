//
//  TestViewController.swift
//  Sparks
//
//  Created by George Vashakidze on 9/27/20.
//  Copyright © 2020 AppWork. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class TestViewController: UIViewController {
    
    var products: [SKProduct] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let restoreButton = UIButton(frame: CGRect(x: view.frame.width / 2 - 125, y: 100, width: 250, height: 60))
        restoreButton.setTitle("Restore", for: .normal)
        view.addSubview(restoreButton)
        restoreButton.addTarget(self, action: #selector(restorePurchases), for: .touchUpInside)
        
        
        let purchaseButton = UIButton(frame: CGRect(x: view.frame.width / 2 - 125, y: 180, width: 250, height: 60))
        purchaseButton.setTitle("Purchase", for: .normal)
        view.addSubview(purchaseButton)
        purchaseButton.addTarget(self, action: #selector(purchaseSubscription), for: .touchUpInside)
        
        let lblProductStatus = UILabel(frame: CGRect(x:0, y: 240, width: view.bounds.width, height: 60))
        view.addSubview(lblProductStatus)
        lblProductStatus.textAlignment = .center
        lblProductStatus.numberOfLines = 0
        
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
        }
        if SparkProductsManager.store.isProductPurchased(SparkProductsManager.sparksAnnualSubscription){
            lblProductStatus.textColor = .green
            lblProductStatus.text = "You already purchased annual item"
        } else {
            lblProductStatus.textColor = .red
            lblProductStatus.text = "You dont have an item.\nPress purchase to buy or restore it"
        }
    }

    @objc func purchaseSubscription(_ sender: Any) {
        guard !products.isEmpty else {
            print("Cannot purchase subscription because products is empty!")
            return
        }
        
        let alertController = UIAlertController(title: "Choose your subscription",
                                                message: "Which subscription option works best for you ?",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: .default,
                                                handler: { action in
                                                    print("close")
                                                }))
        
        
        for (index, product) in products.enumerated() {
            alertController.addAction(UIAlertAction(title: product.localizedTitle,
                                                    style: .default,
                                                    handler: { action in
                                                        self.purchaseItemIndex(index: index)
                                                    }))
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func restorePurchases(_ sender: Any) {
        SparkProductsManager.store.restorePurchases()
    }
    
    private func purchaseItemIndex(index: Int) {
        SparkProductsManager.store.buyProduct(products[index]) { [weak self] success, productId in
            guard let self = self else { return }
            guard success else {
                let alertController = UIAlertController(title: "Failed to purchase product",
                                                        message: "Check logs for details",
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertController, animated: true, completion: nil)
                return
            }
        }
    }
    
}
