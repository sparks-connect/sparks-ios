//
//  TripView.swift
//  Sparks
//
//  Created by Adroit Jimmy on 14/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

protocol ListPresenter: AnyObject {
    var datasource: [Trip]? {get set}
    func configureCell(cell: TripCell, indexPath: IndexPath)
    func didSelectCell(index: Int)
}

class TripView<T: ListPresenter>: UIView, UICollectionViewDataSource, UICollectionViewDelegate{
    
    var presenter: T!
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width * 0.44, height: 195)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 12
        let colView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colView.translatesAutoresizingMaskIntoConstraints = false
        colView.dataSource = self
        colView.delegate = self
        colView.backgroundColor = .clear
        colView.register(TripCell.self, forCellWithReuseIdentifier: "cell")
        return colView
    }()
    
    
    init(presenter: T){
        super.init(frame: .zero)
        self.presenter = presenter
        
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func reload(){
        self.collectionView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.presenter.datasource?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TripCell else { return UICollectionViewCell() }
        self.presenter.configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.presenter.didSelectCell(index: indexPath.item)
    }
    
}
