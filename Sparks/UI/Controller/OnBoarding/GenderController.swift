//
//  GenderController.swift
//  Sparks
//
//  Created by Nika Samadashvili on 6/7/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import SnapKit

fileprivate extension Gender {
    var tag: Int {
        switch self {
        case .female: return 0
        case .male: return 1
        case .both: return 2
        }
    }
    
    init(tag: Int) {
        switch tag {
        case Gender.male.tag:
            self = .male
        case Gender.female.tag:
            self = .female
        default:
            self = .both
        }
    }
}

class GenderController : PageBaseController {
    
    private let presenter = GenderPresenter()
    override func getPresenter() -> Presenter {
        return presenter
    }
    
    private var genderButtons : [CircleLoadingButton] = []
    
    private lazy var welcomeLabel : UILabel = {
        let view = Label()
        view.font =  UIFont.systemFont(ofSize: 22, weight: .bold)
        view.textColor = .white
        view.text = "Onboarding"
        return view
    }()
    
    private let titeLabel : Label = {
        let view = Label()
        view.textAlignment = .center
        view.font =  UIFont.systemFont(ofSize: 32, weight:.bold)
        view.numberOfLines = 0
        view.textAlignment = .left
        view.textColor = .white
        view.text = "Choose Your Gender"
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
    
    private let genderButtonStack : UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 15
        view.distribution = .fillEqually
        return view
    }()
    
    private let femaleButton : CircleLoadingButton = {
        let view = CircleLoadingButton()
        view.setBackgroundColor(Color.purple.uiColor, forState: .disabled)
        view.setBackgroundColor(Color.fadedPurple.uiColor, forState: .normal)
        view.setTitle(Gender.female.rawValue, for: .normal)
        view.setBorderWidth(0, forState: .normal)
        view.setBorderWidth(0, forState: .disabled)
        view.tag = Gender.female.tag
        return view
    }()
    
    private let maleButton : CircleLoadingButton = {
        let view = CircleLoadingButton()
        view.setBackgroundColor(Color.purple.uiColor, forState: .disabled)
        view.setBackgroundColor(Color.fadedPurple.uiColor, forState: .normal)
        view.setTitle(Gender.male.rawValue, for: .normal)
        view.setBorderWidth(0, forState: .normal)
        view.setBorderWidth(0, forState: .disabled)
        view.tag = Gender.male.tag
        return view
    }()
    
    private let otherButton : CircleLoadingButton = {
        let view = CircleLoadingButton()
        view.setBackgroundColor(Color.purple.uiColor, forState: .disabled)
        view.setBackgroundColor(Color.fadedPurple.uiColor, forState: .normal)
        view.setBorderWidth(0, forState: .normal)
        view.setBorderWidth(0, forState: .disabled)
        view.setTitle(Gender.both.rawValue, for: .normal)
        view.tag = Gender.both.tag
        return view
    }()
    
    private let nextButton : LoadingButton = {
        let view = LoadingButton()
        view.setBackgroundColor(Color.purple.uiColor, forState: .normal)
        view.setBackgroundColor(.clear, forState: .disabled)
        view.setBorderWidth(0, forState: .normal)
        view.setBorderWidth(1, forState: .disabled)
        view.setTitle("Next", for: .normal)
        view.cornerRadius = 20
        view.isEnabled = false
        return view
    }()
    
    var isEditMode: Bool = false {
        didSet {
            if self.isEditMode {
                self.welcomeLabel.isHidden = true
                self.nextButton.setTitle("Update", for: .normal)
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        layout()
    }
    
    override func customInit() {
        super.customInit()
        genderButtons.append(femaleButton)
        genderButtons.append(maleButton)
        genderButtons.append(otherButton)
        
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(didTapOnGender), for: .touchUpInside)
        maleButton.addTarget(self, action: #selector(didTapOnGender), for: .touchUpInside)
        otherButton.addTarget(self, action: #selector(didTapOnGender), for: .touchUpInside)
    }
    
    private func layout() {
        view.addSubview(welcomeLabel)
        welcomeLabel.snp.makeConstraints {
            $0.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
        }
        
        view.addSubview(titeLabel)
        titeLabel.snp.makeConstraints{
            $0.top.equalTo(welcomeLabel.snp.bottom).inset(-100)
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
        
        view.addSubview(genderButtonStack)
        genderButtonStack.snp.makeConstraints {
            $0.top.equalTo(nextButton.snp.top).inset(-250)
            $0.left.right.equalToSuperview().inset(50)
            $0.height.equalTo(50)
        }
        
        genderButtonStack.addArrangedSubview(femaleButton)
        genderButtonStack.addArrangedSubview(maleButton)
        genderButtonStack.addArrangedSubview(otherButton)
    }
    
    @objc private func didTapNextButton(_ sender: Any){
        nextButton.startAnimatingLoader()
        presenter.updateGender()
    }
    
    @objc private func didTapOnGender(_ sender: CircleLoadingButton) {
        onGenderChange(at: sender.tag)
    }
    
    private func onGenderChange(at index: Int) {
        nextButton.isEnabled = false
        for (i, button) in genderButtons.enumerated() {
            button.isEnabled = i != index
        }
        
        presenter.gender = Gender(tag: index)
        nextButton.isEnabled = true
    }
    
    
    
    override func notifyError(message: String, okAction: (() -> Void)? = nil) {
        super.notifyError(message: message)
        self.nextButton.stopAnimatingLoader()
    }
    
    func setGender(_ gender: Gender?) {
        self.presenter.gender = gender
    }
    
    override func reloadView() {
        super.reloadView()
        for (i, button) in genderButtons.enumerated() {
            button.isEnabled = i != self.presenter.gender?.tag
        }
    }
}

extension GenderController: GenderView {
    func didUpdateGender() {
        self.nextButton.stopAnimatingLoader()
        if !isEditMode {
            self.pageViewController?.switchTabToNext(parameters: nil)
        } else {
            self.pageViewController?.didTapAtCloseButton()
        }
    }
}
