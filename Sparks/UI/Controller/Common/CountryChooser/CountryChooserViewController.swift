//
//  CountryChooserViewController.swift
//  Sparks
//
//  Created by George Vashakidze on 7/18/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

protocol CountryChooserViewDelegate: class {
    func onCountrySelected(_ country: Country)
}

class CountryChooserViewController: BottomSheetController {
    
    weak var delegate: CountryChooserViewDelegate?
    
    lazy private var listView : ListView = {
        let view = ListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private(set) var titleLabel : Label = {
        let view = Label()
        view.textColor = .white
        view.font = Font.bold.uiFont(ofSize: 16)
        view.text = "Select your country code"
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
  
    override func configure() {
        super.configure()
        self.setupListView()
        self.listView.reloadData()
    }
    
    override var popupViewHeight: CGFloat {
        return UIScreen.main.bounds.height - UIScreen.main.bounds.height / 5.8
    }
    
    private let presenter = CountryChooserPresenter()
    
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    override func loadView() {
        super.loadView()
        self.layoutSubviews()
    }
    
    private func layoutSubviews() {
        popupView.addSubview(listView)
        popupView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(popupView.snp.left).offset(24)
            $0.top.equalTo(popupView.safeAreaLayoutGuide.snp.top).inset(24)
        }
        
        listView.snp.makeConstraints {
            $0.left.equalTo(popupView.snp.left).offset(0)
            $0.right.equalTo(popupView.snp.right).offset(0)
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.bottom.equalTo(popupView.snp.bottom).offset(0)
        }
        self.popupView.backgroundColor = Color.buttonColor.uiColor
    }
    
    private func setupListView(){
        listView.separatorStyle = .none
        listView.backgroundColor = .clear
        listView.separatorInset  = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        listView.cellNibIdentifiers = ["CountryCell": "CountryCell"]
        listView.cellReuseIdentifier = {(indexPath) in return "CountryCell" }
        listView.heightForRow = {(indexPath) in return 45 }
        listView.sectionCount = ({ return 1 })
        listView.numberOfRows = {[weak self](section) in return self?.presenter.numberOfItems ?? 0 }
        listView.cellDelegate = {(indexPath) in return self }
        listView.parameterForRow = {[weak self](indexPath) in
            return self?.presenter.item(atIndexPath: indexPath)
        }
        listView.didSelectRow = {[weak self](indexPath) in
            guard let country = self?.presenter.item(atIndexPath: indexPath) else { return }
            self?.delegate?.onCountrySelected(country)
            self?.dismiss(animated: true, completion: nil)
        }
    }
}

extension CountryChooserViewController: TableViewCellDelegate {
    
}

