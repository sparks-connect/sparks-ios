//
//  UserPreferencesPresenter.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 5/28/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import UIKit

protocol UserPreferencesView: BasePresenterView {
    
}

class UserPreferencesPresenter: BasePresenter<UserPreferencesView> {
    
    private let service = Service.auth
    let MIN_AGE = 18
    let MAX_AGE = 80
    var step: CGFloat {
        CGFloat(100)/CGFloat(MAX_AGE - MIN_AGE)
    }
    
    private(set) var genderPreference = Gender.both
    private(set) var minAge: Int = FirebaseConfigManager.shared.minAgePref
    private(set) var maxAge: Int = FirebaseConfigManager.shared.maxAgePref
    private(set) var distance: Int = FirebaseConfigManager.shared.distancePref
    private var prevMin = 0
    private var prevMax = 0
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        self.reload()
        
        RealmUtils.observeUserUpdates {
            self.reload()
        }
    }
    
    private func reload() {
        guard let user = User.current else { return }
        genderPreference = user.genderPreferenceEnum ?? .both
        minAge = Int(round(CGFloat(user.minAge - MIN_AGE) * CGFloat(step)))
        maxAge = Int(round(CGFloat(user.maxAge - MIN_AGE) * CGFloat(step)))
        self.prevMin = minAge
        self.prevMax = minAge
        distance = user.distance
        self.view?.reloadView()
    }
    
    func setGenderPreference(_ preference: Gender) {
        self.genderPreference = preference
        self.view?.reloadView()
    }
    
    func setMinAge(_ age: Int) {
        
        if abs(originalAge(self.maxAge) - originalAge(age)) > 5 {
            self.minAge = age
        }

        prevMin = self.minAge
    }
    
    func setMaxAge(_ age: Int) {
        if abs(originalAge(age) - originalAge(self.minAge)) > 5 {
            self.maxAge = age
        }

        prevMax = self.maxAge
    }
    
    func setDistance(_ distance: Int) {
        self.distance = distance
    }
    
    func originalAge(_ age: Int) -> Int {
        MIN_AGE + Int(round(CGFloat(age) / step))
    }
    
    func update() {
        
        let min = originalAge(self.minAge)
        let max = originalAge(self.maxAge)
        
        self.service.updatePreferences(gender: self.genderPreference,
                                       minAge: min,
                                       maxAge: max,
                                       distance: self.distance) {[weak self] (response) in
            self?.handleResponse(response: response)
        }
    }
}
