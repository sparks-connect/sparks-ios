//
//  TripsTableViewCell.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 01.04.22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import UIKit

extension TripCollection: TableViewCellParameter {
    
}

class TripsTableViewCell: TableViewCell {
    
    private var object: TripCollection? {
        return self.parameter as? TripCollection
    }
    
    lazy private var labelHeader: Label = {
        let view = Label()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.font(for: 24, style: .bold)
        view.textColor = .white
        return view
    }()
    
    private lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    override func setup() {
        super.setup()
        self.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TripCell.self, forCellWithReuseIdentifier: TripCell.description())
        self.contentView.backgroundColor = .clear
        layout()
    }
    
    override func configure(parameter: TableViewCellParameter?, delegate: TableViewCellDelegate?) {
        super.configure(parameter: parameter, delegate: delegate)
        self.labelHeader.text = object?.header
        self.collectionView.reloadData()
    }
    
    private func layout() {
        self.contentView.addSubview(labelHeader)
        labelHeader.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(16)
            make.height.equalTo(40)
            make.right.equalTo(-16)
        }
        
        self.contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-8)
            make.top.equalTo(labelHeader.snp.bottom).offset(16)
        }
    }
    
    private func configureCell(cell: TripCell, indexPath: IndexPath){
        guard let object = self.object else { return }
        
        guard let user = User.current, indexPath.row < object.trips.count else {return}
        let trip = object.trips[indexPath.item]
        let stDate = trip.startDate.toDate.toString("dd MMM", localeIdentifier: Locale.current.identifier)
        let endDate = trip.endDate.toDate.toString("dd MMM", localeIdentifier: Locale.current.identifier)
        let date = "\(stDate) - \(endDate)"
        let profile = "\(trip.user?.firstName ?? ""), \(trip.user?.ageYear ?? 0)"
        
        cell.configure(indexPath: indexPath,
                       url: trip.user?.photoUrl ?? "",
                       date: date,
                       name: profile,
                       location: trip.city ?? "",
                       desc: trip.plan ?? "",
                       isFav: user.isTripFavourite(uid: trip.uid),
                       gender: trip.user?.genderEnum ?? .both
                    )
        cell.makeFavourite = {[weak self] (indexPath) in
            // self?.addToFavourite(indexPath: indexPath)
        }
    }
}

extension TripsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return object?.trips.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TripCell.description(), for: indexPath as IndexPath) as! TripCell
        configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height )
    }
}
