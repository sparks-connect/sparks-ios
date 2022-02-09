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
    
    let datasource = [
                        PreviewModel(icon: "icn-loc", text: "Vienna, Austria"),
                        PreviewModel(icon: "icn-cal", text: "10 Dec, 2021 - 14 Dec, 2021"),
                        PreviewModel(icon: "icn-purpose", text: "Leisure"),
                        PreviewModel(icon: "icn-grp", text: "With friends"),
                        PreviewModel(icon: "icn-info", text: "Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum")
                     ]
    private lazy var preview : Preview = {
        let view = Preview(data: datasource)
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
        self.presenter.create()
    }
    
}

extension TripPreviewController: PreviewView {
    func navigate() {
        self.delegate?.create()
    }
}

struct PreviewModel {
    var icon: String?
    var text: String?
}

class Preview: UIView{
    private var data = [PreviewModel](){
        didSet{
            self.tableView.reloadData()
        }
    }
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

    init(data: [PreviewModel]){
        super.init(frame: .zero)
        layout()
        self.data = data
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
}

extension Preview: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PreviewCell else { return UITableViewCell() }
        let previewModel = self.data[indexPath.row]
        cell.configure(icn: previewModel.icon, text: previewModel.text)
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
