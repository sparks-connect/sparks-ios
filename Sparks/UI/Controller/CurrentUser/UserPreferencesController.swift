//
//  CurrentUserSettingsController.swift
//  Sparks
//
//  Created by George Vashakidze on 3/22/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit

final class UserPreferencesController: BaseController, UserPreferencesView, MainHeaderViewDelegate {
    
    private let presenter = UserPreferencesPresenter()
    override func getPresenter() -> Presenter {
        return presenter
    }
    
    private struct Sizes {
        static let sliderMargin: CGFloat = 24
        static let sliderWidth: CGFloat = UIScreen.main.bounds.width - 2 * Sizes.sliderMargin
        static let sliderHeight: CGFloat = 20
    }

    //MARK: properties
    private let distanceSlider = RangeSlider(frame: .zero)
    private let ageRangeSlider = RangeSlider(frame: .zero)
    
    lazy private var maleButton : GenderButton = {
        let button = GenderButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel.text = "Boy"
        return button
    }()
    
    lazy private var femaleButton : GenderButton = {
        let button = GenderButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel.text = "Girl"
        return button
    }()
    
    lazy private var bothButton : GenderButton = {
        let button = GenderButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel.text = "Both"
        return button
    }()
    
    lazy private var stackview: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.distribution = .fillEqually
        sv.axis = .horizontal
        sv.spacing = 17
        return sv
    }()
    
    lazy private var genderContainerView: UserFilterPreferenceBlockView = {
        let view = UserFilterPreferenceBlockView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = Image.profile.uiImage
        view.titleLeft = "Gender"
        return view
    }()
    
    lazy private var distanceContainerView: UserFilterPreferenceBlockView = {
        let view = UserFilterPreferenceBlockView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = Image.location.uiImage
        view.titleLeft = "Maximum Distance"
        view.titleRight = "0km"
        return view
    }()
    
    lazy private var ageRangeContainerView: UserFilterPreferenceBlockView = {
        let view = UserFilterPreferenceBlockView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = Image.ageRange.uiImage
        view.titleLeft = "Age Range"
        view.titleRight = "22-32"
        return view
    }()
    
    //MARK: public functions
    
    override func configure() {
        super.configure()
        self.navigationItem.title = "Discovery preferences"
    }
    
    override func loadView() {
        super.loadView()
        configureSubviews()
    }

    override func reloadView() {
        super.reloadView()
        
        configureGenderButtons()

        switch presenter.genderPreference {
        case .male: maleButton.isSelected = true
        case .female: femaleButton.isSelected = true
        case .both: bothButton.isSelected = true
        }
        
        distanceSlider.minimumValue = 0
        distanceSlider.maximumValue = 1
        distanceSlider.lowerValue = 0
        distanceSlider.upperValue = CGFloat(Double(presenter.distance) / 100)
        
        ageRangeSlider.minimumValue = 0
        ageRangeSlider.maximumValue = 1
        ageRangeSlider.lowerValue = CGFloat(Double(presenter.minAge) / 100)
        ageRangeSlider.upperValue = CGFloat(Double(presenter.maxAge) / 100)
        
        distanceContainerView.titleRight = "\(self.presenter.distance)KM"
        
        let min = self.presenter.MIN_AGE + Int(round(CGFloat(self.presenter.minAge) / self.presenter.step))
        let max = self.presenter.MIN_AGE + Int(round(CGFloat(self.presenter.maxAge) / self.presenter.step))
        ageRangeContainerView.titleRight = "\(min)-\(max)"
                
    }
    
    override func willDisappear() {
        super.willDisappear()
        presenter.update()
    }
    
    @objc private func didTapAtButton(_ gesture: UIGestureRecognizer) {
        guard let button = gesture.view as? GenderButton else { return }
        configureGenderButtons()
        button.isSelected = true
        
        switch button.tag {
        case 0: self.presenter.setGenderPreference(.male)
        case 1: self.presenter.setGenderPreference(.female)
        case 2: self.presenter.setGenderPreference(.both)
        default:
            break
        }
    }
    
    @objc private func onSliderValueChange(_ slider: RangeSlider) {
        switch slider.tag {
        case 0:
            presenter.setDistance(Int(slider.upperValue * 100))
        default:
            
            let min = Int(slider.lowerValue * 100)
            let max = Int(slider.upperValue * 100)
            
            presenter.setMinAge(min)
            presenter.setMaxAge(max)
        }
    }
    
    @objc private func onSliderEditingEnd(_ slider: RangeSlider) {
        self.reloadView()
    }
    
    func didTapOnActionButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension UserPreferencesController {
    
    private func addSubViews() {
        view.addSubview(genderContainerView)
        view.addSubview(distanceContainerView)
        view.addSubview(ageRangeContainerView)
        stackview.addArrangedSubview(maleButton)
        stackview.addArrangedSubview(femaleButton)
        stackview.addArrangedSubview(bothButton)
    }
    
    private func configureLayout() {
        
        distanceSlider.tag = 0
        ageRangeSlider.tag = 1
        
        distanceSlider.hasSingleDirection = true
        ageRangeSlider.hasSingleDirection = false
        
        maleButton.tag = 0
        femaleButton.tag = 1
        bothButton.tag = 2
        
        maleButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAtButton(_ :))))
        femaleButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAtButton(_ :))))
        bothButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAtButton(_ :))))
               
        maleButton.backgroundColor = .clear
        femaleButton.backgroundColor = .clear
        bothButton.backgroundColor = .clear
        
        distanceSlider.addTarget(self, action: #selector(onSliderValueChange(_:)), for: .valueChanged)
        ageRangeSlider.addTarget(self, action: #selector(onSliderValueChange(_:)), for: .valueChanged)
        distanceSlider.addTarget(self, action: #selector(onSliderEditingEnd(_:)), for: .editingDidEnd)
        ageRangeSlider.addTarget(self, action: #selector(onSliderEditingEnd(_:)), for: .editingDidEnd)

        distanceSlider.trackHighlightTintColor = Color.purple.uiColor
        ageRangeSlider.trackHighlightTintColor = Color.purple.uiColor
                
    }
    
    private func configureSubviews() {
        
        addSubViews()
                     
        buildGenderViews()
        
        buildLocationViews()
        
        buildAgeRangeViews()
        
        configureLayout()
    }
    
    private func configureGenderButtons() {
        stackview.subviews.forEach({
            guard let button = $0 as? GenderButton else { return }
            button.isSelected = false
        })
    }
    
    private func buildGenderViews() {
        genderContainerView.snp.makeConstraints({
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(8)
            $0.height.equalTo(136)
        })
        
        let container = UIView()
        container.backgroundColor = .clear
        
        genderContainerView.primaryContentView = container
        
        let label = UILabel()
        label.contentMode = .left
        label.textColor = Color.lightPurple.uiColor
        label.font = Font.regular.uiFont(ofSize: 12)
        label.text = "I want to chat with"
        
        container.addSubview(label)
        container.addSubview(stackview)
        
        label.snp.makeConstraints({
            $0.left.equalTo(0)
            $0.top.equalTo(8)
        })
        
        stackview.snp.makeConstraints({
            $0.left.equalTo(0)
            $0.top.equalTo(label.snp.bottom).offset(16)
            $0.right.equalTo(0)
            $0.height.equalTo(32)
        })
    }
    
    private func buildLocationViews() {
        distanceContainerView.snp.makeConstraints({
            $0.top.equalTo(genderContainerView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(136)
        })
        
        
        let container = UIView()
        container.backgroundColor = .clear
        distanceContainerView.primaryContentView = container
        
        let label = UILabel()
        label.contentMode = .left
        label.textColor = Color.lightPurple.uiColor
        label.font = Font.regular.uiFont(ofSize: 12)
        label.text = "Set the distance from your location"
        
        container.addSubview(label)
        container.addSubview(distanceSlider)
        label.snp.makeConstraints({
            $0.left.equalTo(0)
            $0.bottom.equalTo(container.snp.bottom).offset(-24)
        })
        
        distanceSlider.frame = CGRect(x: 0, y: 16, width: UIScreen.main.bounds.width - 116, height: 20)
    }
    
    private func buildAgeRangeViews() {
        ageRangeContainerView.snp.makeConstraints({
            $0.top.equalTo(distanceContainerView.snp.bottom)
            $0.left.equalTo(view.snp.left)
            $0.right.equalTo(view.snp.right)
            $0.height.equalTo(136)
        })
        
        let container = UIView()
        container.backgroundColor = .clear
        
        ageRangeContainerView.primaryContentView = container
        
        let label = UILabel()
        label.contentMode = .left
        label.textColor = Color.lightPurple.uiColor
        label.font = Font.regular.uiFont(ofSize: 12)
        label.text = "Set the preffered age range"
        
        container.addSubview(label)
        container.addSubview(ageRangeSlider)
      
        label.snp.makeConstraints({
            $0.left.equalTo(0)
            $0.bottom.equalTo(container.snp.bottom).offset(-24)
        })
        
        ageRangeSlider.frame = CGRect(x: 0, y: 16, width: UIScreen.main.bounds.width - 116, height: 20)
    }
}
