//
//  CountryChooserPresenter.swift
//  Sparks
//
//  Created by George Vashakidze on 7/18/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation

protocol CountryChooserView: BaseView {
    
}

class CountryChooserPresenter: BasePresenter<CountryChooserView> {
    private var datasource = [Country]()
    
    override init() {
        super.init()
        self.datasource = FirebaseConfigManager.shared.countries.sorted(by: sort)
    }
    
    func sort(c1: Country, c2: Country) -> Bool {
        return c1.name < c2.name
    }
    
    var numberOfItems: Int {
        return datasource.count
    }
    
    func item(atIndexPath indexPath: IndexPath) -> Country? {
        guard indexPath.row < datasource.count else { return nil }
        return datasource[indexPath.row]
    }

}
