//
//  ListView.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 3/5/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate: AnyObject {}

protocol TableViewCellParameter {}

class TableViewCell: UITableViewCell {
    
    static var reuseIdentifier: String { return "cell" }
    private(set) weak var delegate: TableViewCellDelegate?
    private(set) var parameter: TableViewCellParameter?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        self.selectionStyle = .none
    }
    
    func configure(parameter: TableViewCellParameter?, delegate: TableViewCellDelegate?) {
        self.delegate = delegate
        self.parameter = parameter
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.reset()
    }
    
    func reset() {
        
    }
    
    func willDisplayCell() {
        
    }
    
    func willEndDisplayCell() {
        NotificationCenter.default.removeObserver(self)
    }
}

class ListView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var cellNibIdentifiers = [String: String]() {
        didSet {
            setup()
        }
    }
    
    var cellClassIdentifiers = [String: AnyClass]() {
        didSet {
            setup()
        }
    }
    
    var headerFooterNibIdentifiers = [String: String]() {
        didSet {
            setup()
        }
    }
    
    var headerFooterClassIdentifiers = [String: AnyClass]() {
        didSet {
            setup()
        }
    }
    
    var refreshControlIsEnabled: (() -> Bool)?
    var willRefreshList: (() -> Void)?
    var sectionCount: (() -> Int)?
    var numberOfRows: ((Int) -> Int)?
    var cellDelegate: ((IndexPath) -> TableViewCellDelegate)?
    var cellReuseIdentifier: ((IndexPath) -> String)?
    var headerFooterReuseIdentifier: ((Int) -> String)?
    var heightForRow: ((IndexPath) -> CGFloat)?
    var heightForHeader: ((Int) -> CGFloat)?
    var heightForFooter: ((Int) -> CGFloat)?
    var didSelectRow: ((IndexPath) -> Void)?
    var headerTitle: ((Int) -> String)?
    var footerTitle: ((Int) -> String)?
    var headerView: ((Int) -> UIView)?
    var footerView: ((Int) -> UIView)?
    var canMoveRow: ((IndexPath) -> Bool)?
    var moveRow: ((IndexPath, IndexPath) -> Void)?
    var commitEditingStyle: ((IndexPath, UITableViewCell.EditingStyle) -> Void)?
    var canEditRow: ((IndexPath) -> Bool)?
    var shouldIndentWhileEditingRow: ((IndexPath) -> Bool)?
    var willDisplayCell: ((UITableViewCell, IndexPath) -> Void)?
    var parameterForRow: ((IndexPath) -> TableViewCellParameter?)?
    var didTapEmptyListButton: (() -> Void)?
    
    private func setup() {
        
        self.cellNibIdentifiers.forEach { (key, value) in
            self.register(UINib(nibName: value, bundle: nil), forCellReuseIdentifier: key)
        }
        
        self.cellClassIdentifiers.forEach { (key, value) in
            self.register(value, forCellReuseIdentifier: key)
        }
        
        self.headerFooterNibIdentifiers.forEach { (key, value) in
            self.register(UINib(nibName: value, bundle: nil), forHeaderFooterViewReuseIdentifier: key)
        }
        
        self.headerFooterClassIdentifiers.forEach { (key, value) in
            self.register(value, forHeaderFooterViewReuseIdentifier: key)
        }
        
        self.delegate = self
        self.dataSource = self
    }

    override func reloadData() {
        super.reloadData()
        self.endRefreshing()
    }
    
    private func setupRefreshControl() {
        
        if refreshControlIsEnabled?() ?? false {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self, action: #selector(pull2Refresh(sender:)), for: .valueChanged)
            self.refreshControl?.backgroundColor = .clear
            self.refreshControl?.tintColor = self.tintColor
        }
    }
    
    @objc func pull2Refresh(sender: UIRefreshControl) {
        willRefreshList?()
    }
    
    private func endRefreshing() {
        if self.refreshControl?.isRefreshing == true {
            self.refreshControl?.endRefreshing()
        }
    }
  
//MARK: UITableViewDatasource & UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount?() ?? 1
    }
    
    @objc func didTapEmptyListAction(target: Any?){
        didTapEmptyListButton?()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows?(section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = cellReuseIdentifier?(indexPath) ?? "cell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) else { return UITableViewCell() }
        (cell as? TableViewCell)?.configure(parameter: parameterForRow?(indexPath), delegate: cellDelegate?(indexPath))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return heightForFooter?(section) ?? CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightForHeader?(section) ?? CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        willDisplayCell?(cell, indexPath)
        (cell as? TableViewCell)?.willDisplayCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { return headerView?(section) }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { didSelectRow?(indexPath) }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return heightForRow?(indexPath) ?? 0 }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return headerTitle?(section) }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? { return footerTitle?(section) }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let reuseIdent = headerFooterReuseIdentifier?(section) ?? ""
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdent)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool { return canMoveRow?(indexPath) ?? false }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveRow?(sourceIndexPath, destinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        commitEditingStyle?(indexPath, editingStyle)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return canEditRow?(indexPath) ?? false }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return shouldIndentWhileEditingRow?(indexPath) ?? false
    }
}

class DemoListController: UIViewController, TableViewCellDelegate {
    
    private(set) var tableView = ListView()
    private var dataSource = [ConversationItem]()
    
    override func viewDidLoad() {
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        for i in 0...10 {
            dataSource.append(ConversationItem(text: "Conv \(i)"))
        }
        
        configureListView()
    }
    
    private func configureListView() {
        tableView.cellClassIdentifiers = ["classCell": TableViewCell.self, "classCell2": UITableViewCell.self]
        tableView.cellReuseIdentifier = {(indexPath) in return "classCell" }
        tableView.heightForRow = {(indexPath) in return 64 }
        tableView.numberOfRows = {(section) in return 10 }
        tableView.willDisplayCell = {[weak self](cell, indexPath) in cell.textLabel?.text = self?.dataSource[indexPath.row].text }
        tableView.cellDelegate = {(indexPath) in return self }
        tableView.parameterForRow = {[weak self](indexPath) in self?.dataSource[indexPath.row] }
        tableView.reloadData()
    }
}

class ConversationItem: TableViewCellParameter {
    var text: String
    init(text: String) {
        self.text = text
    }
}
