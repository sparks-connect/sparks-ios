//
//  BirthDateController.swift
//  Sparks
//
//  Created by Nika Samadashvili on 6/7/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import SnapKit

class BirthDateController : PageBaseController {
    
    private let presenter = BirthDatePresenter()
    
    override func getPresenter() -> Presenter {
        return presenter
    }
    
    private let titeLabel : Label = {
        let view = Label()
        view.textAlignment = .center
        view.font =  UIFont.systemFont(ofSize: 32, weight:.bold)
        view.numberOfLines = 0
        view.textAlignment = .left
        view.textColor = .white
        view.text = "Select Your Birth Date"
        return view
    }()
    
    private let descriptionLabel : Label = {
        let view = Label()
        view.textAlignment = .center
        view.font =  UIFont.systemFont(ofSize: 14, weight:.medium)
        view.textColor = Color.fadedPurple.uiColor
        view.text = "Spin and get more than swipes"
        return view
    }()
    
    private let datePicker : UIDatePicker = {
        let view = UIDatePicker()
        view.datePickerMode = .date
        if #available(iOS 13.4, *) {
            view.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        view.setValue(Color.fadedPurple.uiColor, forKey: "textColor")
        return view
    }()
    
    private let nextButton : LoadingButton = {
        let view = LoadingButton()
        view.setBackgroundColor(Color.purple.uiColor, forState: .normal)
        view.setBorderWidth(0, forState: .normal)
        view.setBorderWidth(1, forState: .disabled)
        view.setTitle("Next", for: .normal)
        
        view.cornerRadius = 20
        return view
    }()
    
    override func loadView() {
        super.loadView()
        layout()
    }
    
    override func configure() {
        super.configure()
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(didChangeDate), for: .valueChanged)
        self.presenter.birthDate = Int64(datePicker.date.milliseconds)
    }
    
    private func layout() {
        
        view.addSubview(titeLabel)
        titeLabel.snp.makeConstraints{
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(100)
            $0.width.equalTo(220)
            $0.left.equalToSuperview().offset(45)
        }
        
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints{
            $0.top.equalTo(titeLabel.snp.bottom).offset(10)
            $0.left.equalTo(titeLabel.snp.left)
        }
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(50)
            $0.bottom.equalToSuperview().inset(36)
            $0.height.equalTo(60)
        }
        
        view.addSubview(datePicker)
        datePicker.snp.makeConstraints {
            $0.bottom.equalTo(nextButton.snp.top).offset(-100)
            $0.left.right.equalToSuperview().inset(-10)
            $0.height.equalTo(180)
        }
        
    }
    
    @objc private func didChangeDate(_ sender: Any){
        self.presenter.birthDate = Int64(datePicker.date.milliseconds)
    }
    
    @objc private func didTapNextButton(_ sender: Any){
        nextButton.startAnimatingLoader()
        presenter.updateBirthDate()
    }
    
    override func notifyError(message: String, okAction: (() -> Void)? = nil) {
        super.notifyError(message: message)
        self.nextButton.stopAnimatingLoader()
    }
    
    func setBirthDate(_ mlsc: Int64?) {
        self.presenter.birthDate = mlsc
        guard let milliseconds = mlsc else { return }
        self.datePicker.date = Date(milliseconds: milliseconds)
    }
    
    override func reloadView() {
        super.reloadView()
        self.datePicker.date = Date.init(milliseconds: self.presenter.birthDate ?? 0)
    }
}

extension BirthDateController : NavigationBarDelegate {
    func didBackCancelButton() {
        self.pageViewController?.switchTabToPrevious()
    }
}

extension BirthDateController: BirthDateView {
    func didUpdateBirthdate() {
        self.nextButton.stopAnimatingLoader()
        AppDelegate.updateRootViewController()
    }
}
