//
//  BaseListController.swift
//  cario
//
//  Created by Irakli Vashakidze on 5/11/19.
//  Copyright © 2019 Cario. All rights reserved.
//

import UIKit

class BaseListController: BaseController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet private(set) weak var tableView: UITableView?
    private var refreshControl: UIRefreshControl?
    
    override func configure() {
        super.configure()
        self.setupTableView()
        self.setupRefreshControl()
    }
    
    func refreshControlIsEnabled() -> Bool { return false }
    
    func shouldRefreshList() {
        // Override in subclasses
    }
    
    func cellNibIdentifiers() -> [String : String] { return [:] }
    func cellClassIdentifiers() -> [String : AnyClass] { return [:] }
    func headerFooterNibIdentifiers() -> [String : String] { return [:] }
    func headerFooterClassIdentifiers() -> [String : AnyClass] { return [:] }
    
    func reloadRows(at: [IndexPath], with: UITableView.RowAnimation) {
        self.tableView?.reloadRows(at: at, with: with)
    }
    
    func reloadSections(at: IndexSet, with: UITableView.RowAnimation) {
        self.tableView?.reloadSections(at, with: with)
    }
    
    private func setupTableView() {
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        
        self.cellNibIdentifiers().forEach { (key, value) in
            self.tableView?.register(UINib(nibName: value, bundle: nil), forCellReuseIdentifier: key)
        }
        
        self.cellClassIdentifiers().forEach { (key, value) in
            self.tableView?.register(value, forCellReuseIdentifier: key)
        }
        
        self.headerFooterNibIdentifiers().forEach { (key, value) in
            self.tableView?.register(UINib(nibName: value, bundle: nil), forHeaderFooterViewReuseIdentifier: key)
        }
        
        self.headerFooterClassIdentifiers().forEach { (key, value) in
            self.tableView?.register(value, forHeaderFooterViewReuseIdentifier: key)
        }
    }
    
    override func reloadView() {
        self.endRefreshing()
        self.tableView?.reloadData()
    }
    
    private func setupRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(pull2Refresh(sender:)), for: .valueChanged)
        self.refreshControl?.backgroundColor = .clear
        self.refreshControl?.tintColor = self.tintColor
        if refreshControlIsEnabled() {
            self.tableView?.refreshControl = self.refreshControl
        }
    }
    
    @objc func pull2Refresh(sender: UIRefreshControl) {
        self.shouldRefreshList()
    }
    
    private func endRefreshing() {
        if self.refreshControl?.isRefreshing == true {
            self.refreshControl?.endRefreshing()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 0 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TableViewCell else { return UITableViewCell() }
        //cell.configure(indexPath: indexPath, delegate: self)
        cell.tintColor = self.tintColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? TableViewCell)?.willDisplayCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Override
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Override
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension BaseListController : TableViewCellDelegate {}
