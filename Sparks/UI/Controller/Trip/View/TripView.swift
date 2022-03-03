//
//  TripView.swift
//  Sparks
//
//  Created by Adroit Jimmy on 14/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol ListPresenter: AnyObject {
    var datasource: [Trip]? {get set}
    func configureCell(cell: TripCell, indexPath: IndexPath)
    func didSelectCell(index: Int)
    func refreshList()
    func fetchNextPage()
}

extension ListPresenter {
    func refreshList() {
        // Consider as optional method for Presenter
    }
    func fetchNextPage(){
        // Consider as optional method for Presenter
    }
}

class TripView<T: ListPresenter>: UIView, UICollectionViewDataSource, UICollectionViewDelegate, PinterestLayoutDelegate, UICollectionViewDelegateFlowLayout {
    
    var presenter: T!
    let randomHeights: [CGFloat] = [300, 200, 280, 220]
    var isPagingStarted: Bool = false
    var isEnablePaging: Bool = false
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = .white
        control.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return control
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let colView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colView.backgroundColor = .clear
        colView.translatesAutoresizingMaskIntoConstraints = false
        colView.alwaysBounceVertical = true
        colView.dataSource = self
        colView.delegate = self
        colView.backgroundColor = .clear
        colView.register(TripCell.self, forCellWithReuseIdentifier: "cell")
        if isEnablePaging {
            colView.refreshControl = refreshControl
        }
        return colView
    }()
    
    
    init(presenter: T, paging: Bool = false){
        super.init(frame: .zero)
        self.presenter = presenter
        self.isEnablePaging = paging
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func reload(){
        isPagingStarted = false
        if isEnablePaging {
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
        self.collectionView.reloadData()
    }
    
    @objc func refresh(){
        self.presenter.refreshList()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Datasource count = \(self.presenter.datasource?.count ?? 0)")
        return self.presenter.datasource?.count ?? 0
    }
      
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TripCell
        self.presenter.configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.presenter.didSelectCell(index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right)) / 2
      return CGSize(width: itemSize, height: itemSize)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
            return randomHeights[Int.random(in: 0..<randomHeights.count)]
        }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isEnablePaging { return }
        if refreshControl.isRefreshing { return }
        if(collectionView.contentOffset.y >= (collectionView.contentSize.height - collectionView.bounds.size.height)) {
            if !isPagingStarted {
                print("add paging....")
                isPagingStarted = true
                self.presenter.fetchNextPage()
            }
        }
    }
}
