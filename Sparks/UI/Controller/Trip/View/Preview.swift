//
//  Preview.swift
//  Sparks
//
//  Created by Adroit Jimmy on 14/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit

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
