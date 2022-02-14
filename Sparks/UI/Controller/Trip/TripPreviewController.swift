//
//  TripPreviewController.swift
//  Sparks
//
//  Created by Adroit Jimmy on 04/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

class TripPreviewController: TripBaseController {
    
    let presenter = TripPreviewPresenter()
    
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    override var parameters: [String : Any]?{
        didSet {
            self.presenter.datasource = parameters?["preview"] as? [PreviewModel]
        }
    }
   
    private lazy var preview : Preview<TripPreviewPresenter> = {
        let view = Preview(presenter: self.presenter)
        return view
    }()
    
    private let minSize: CGFloat = 76.0
    
    override var titleText: String {
        return "Preview your trip"
    }
    
    override var buttonText: String {
        return "Create"
    }
    
    override var buttonColor: UIColor {
        return Color.green.uiColor
    }

    override func configure() {
        super.configure()
        self.delegate?.setTitle(title: "Create Trip")
        self.view.addSubview(preview)
        preview.snp.makeConstraints { make in
            make.leading.equalTo(32)
            make.trailing.equalTo(-32)
            make.top.equalTo(self.titeLabel.snp.bottom).offset(24)
            make.bottom.equalTo(self.nextButton.snp.top).offset(-24)
        }
    }
    
    override func didAppear() {
        super.didAppear()
        main {
            if self.preview.height > self.minSize {
                self.delegate?.updateHeight(height:self.preview.height - self.minSize)
            }
        }
    }
    
    override func nextClicked() {
        self.nextButton.startAnimatingLoader()
        self.delegate?.create(completion:{ isLoaded in
            if isLoaded{
                self.nextButton.stopAnimatingLoader()
            }
        })
    }
    
}


class Preview<T: PreviewConfiguration>: UIView, UITableViewDataSource, UITableViewDelegate{
    var presenter: T!

    private lazy var tableView: SelfSizedTableView = {
        let table = SelfSizedTableView()
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.estimatedRowHeight = 32
        table.isScrollEnabled = false
        table.register(PreviewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    var height: CGFloat {
        return tableView.intrinsicContentSize.height
    }

    init(presenter: T){
        super.init(frame: .zero)
        self.presenter = presenter
        layout()
    }
    
    private func layout(){
        self.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PreviewCell else { return UITableViewCell() }
        self.presenter.configure(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

class PreviewCell: UITableViewCell {
    private lazy var icon: UIImageView = {
        let icn = UIImageView()
        icn.translatesAutoresizingMaskIntoConstraints = false
        return icn
    }()
    
    private lazy var title: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .white
        lbl.numberOfLines = 0
        lbl.font = Font.light.uiFont(ofSize: 16)
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.setup()
    }
    
    private func setup(){
        self.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(16)
            make.height.equalTo(icon.snp.width).multipliedBy(1)
        }
        
        self.addSubview(title)
        title.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(16)
            make.top.equalTo(icon).offset(-3)
            make.trailing.equalToSuperview()
        }
    }
    
    func configure(icn: String?, text: String?){
        icon.image = UIImage(named: icn ?? "")
        title.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SelfSizedTableView: UITableView {
    var maxHeight: CGFloat = UIScreen.main.bounds.size.height
    
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
    
    override var intrinsicContentSize: CGSize {
        setNeedsLayout()
        layoutIfNeeded()
        let height = min(contentSize.height, maxHeight)
        return CGSize(width: contentSize.width, height: height)
    }
}
