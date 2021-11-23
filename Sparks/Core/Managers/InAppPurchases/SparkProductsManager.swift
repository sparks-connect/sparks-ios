//
//  SparkProductsManager.swift
//  Sparks
//
//  Created by George Vashakidze on 9/22/20.
//  Copyright © 2020 AppWork. All rights reserved.
//

import UIKit

struct SparkProductsManager {
    
    private static let productIdentifiers: Set<ProductId> = [SparkProductsManager.sparksAnnualSubscription, SparkProductsManager.sparksMonthlySubscription]
    
    static let sparksAnnualSubscription = "com.appwork.sparks.annualsub"
    static let sparksMonthlySubscription = "com.appwork.sparks.monthly"
    
    static let store = IAPManager(productIds: SparkProductsManager.productIdentifiers)
}

