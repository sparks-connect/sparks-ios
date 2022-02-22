//
//  TripPreviewPresenter.swift
//  Sparks
//
//  Created by Adroit Jimmy on 05/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation

protocol PreviewConfiguration: AnyObject{
    var data: [PreviewModel]? {get}
    func configure(cell: PreviewCell, indexPath: IndexPath)
}

protocol PreviewView: BasePresenterView {
   func navigate()
}

class TripPreviewPresenter: BasePresenter<PreviewView>, PreviewConfiguration {

    var datasource: [PreviewModel]?
    var data: [PreviewModel]?{
        return self.datasource
    }
    
    func configure(cell: PreviewCell, indexPath: IndexPath){
        guard let model = self.datasource?[indexPath.row] else {return}
        cell.configure(icn: model.icon, text: model.text)
    }
}
