//
//  SettingsPresenter.swift
//  Sparks
//
//  Created by George Vashakidze on 6/6/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import UIKit

protocol SettingsView: BasePresenterView {
    func reloadView(atIndexPath indexPath: IndexPath)
    func openSecurity()
    func openFilter()
    func logout()
    func openTerms()
    func copyShareLink()
    func deactivate()
}

enum SettingItemType: String, Decodable {
    case filter
    case logout
    case security
    case terms
    case share
    case deactivate
}

struct SettingsItem: Decodable, TableViewCellParameter {
    let image: String
    let title: String
    let subTitle: String?
    let type: SettingItemType
    
    func settingItemImage() -> UIImage? {
        return UIImage(named: image)
    }
}

class SettingsPresenter: BasePresenter<SettingsView> {
    
    private var datasource = [SettingsItem]()
    
    override init() {
        super.init()
        self.datasource = FirebaseConfigManager.shared.settings
    }
    
    var numberOfItems: Int {
        return datasource.count
    }
    
    func settingsItem(atIndexPath indexPath: IndexPath) -> SettingsItem? {
        guard indexPath.row < datasource.count else { return nil }
        return datasource[indexPath.row]
    }
    
    func handleTap(type: SettingItemType) {
        switch type {
        case .logout:
            self.view?.logout()
        case .filter:
            self.view?.openFilter()
        case .deactivate:
            self.view?.deactivate()
        case .security:
            self.view?.openSecurity()
        case .terms:
            self.view?.openTerms()
        case .share:
            self.view?.copyShareLink()
        }
    }
    
}
