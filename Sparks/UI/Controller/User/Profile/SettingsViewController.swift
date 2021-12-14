//
//  SettingsViewController.swift
//  Sparks
//
//  Created by George Vashakidze on 5/26/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

class SettingsViewController: BaseController {
    
    let presenter = SettingsPresenter()
    
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    lazy private var listView : ListView = {
        let view = ListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func configure() {
        super.configure()
        self.navigationItem.title = "Settings"
        configureLayout()
        setupListView()
        listView.reloadData()
    }
    
    private func configureLayout() {
        
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.left.equalTo(view.snp.left).offset(0)
            $0.right.equalTo(view.snp.right).offset(0)
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalTo(view.snp.bottom)
        }
    }
    
    private func setupListView(){
        listView.separatorStyle = .none
        listView.backgroundColor = .clear
        listView.separatorInset  = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        listView.cellClassIdentifiers = ["SettingsCell": SettingsCell.self]
        listView.cellReuseIdentifier = {(indexPath) in return "SettingsCell" }
        listView.heightForRow = {(indexPath) in return 86 }
        listView.sectionCount = ({ return 1 })
        listView.numberOfRows = {[weak self](section) in return self?.presenter.numberOfItems ?? 0 }
        listView.cellDelegate = {(indexPath) in return self }
        listView.parameterForRow = {[weak self](indexPath) in
            return self?.presenter.settingsItem(atIndexPath: indexPath)
        }
        listView.didSelectRow = {[weak self](indexPath) in
            guard let settingsItem = self?.presenter.settingsItem(atIndexPath: indexPath) else { return }
            self?.presenter.handleTap(type: settingsItem.type)
        }
    }
    
    @objc func onProfileEdit() {
        let editProfileController = EditProfileViewController()
        self.navigationController?.pushViewController(editProfileController, animated: true)
    }
    
}

extension SettingsViewController: SettingsView, TableViewCellDelegate {
    func openSecurity() {
        
    }
    
    func openFilter() {
        let controller = UserPreferencesController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func openTerms() {
        
    }
    
    func deactivate() {
        
    }
    
    func reloadView(atIndexPath indexPath: IndexPath) {
        listView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func updateSection(_ section: Int, deletions: [Int], insertions: [Int], modifications: [Int]) {
        listView.updateSection(0, with: .automatic, deletions: deletions, insertions: insertions, modifications: modifications)
    }
    
    func logout() {
        Service.auth.logout()
        AppDelegate.updateRootViewController()
    }
    
    func copyShareLink() {
        
        guard let link = User.current?.dynamicLink, let url = URL(string: link) else { return }
        
        let linkToShare = [ url ]
        let activityViewController = UIActivityViewController(activityItems: linkToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        self.present(activityViewController, animated: true, completion: nil)
    }
}


extension SettingsViewController: MainHeaderViewDelegate {
    func didTapOnActionButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
