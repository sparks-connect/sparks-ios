//
//  TripSearchController.swift
//  Sparks
//
//  Created by Adroit Jimmy on 09/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import UIKit
import AMPopTip
import Toast_Swift

protocol TripSearchControllerDelegate: AnyObject {
    func tripSearchControllerWillSearch()
}

class TripSearchController: BaseController {
    
    weak var delegate: TripSearchControllerDelegate?
    
    private let presenter = TripSearchPresenter()
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    private lazy var searchContainer: UIView = {
        let vw = UIView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    private lazy var searchIcon: UIImageView = {
        let img = UIImageView(image: UIImage(named: "search"))
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private lazy var searchLabel: UILabel = {
        let lbl = Label()
        lbl.textAlignment = .left
        lbl.font =  UIFont.systemFont(ofSize: 16, weight:.light)
        lbl.numberOfLines = 0
        lbl.textAlignment = .left
        lbl.textColor = .white
        lbl.alpha = 0.4
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.5
        lbl.text = "Type city name..."
        lbl.isUserInteractionEnabled = true
        lbl.addTapGesture(target: self, selector: #selector(navigateToPlaces))
        return lbl
    }()
    
    private lazy var locationResetIcon: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setBackgroundImage(UIImage(named: "loc-remove"), for: .normal)
        btn.addTarget(self, action: #selector(resetLocation), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    private lazy var closeIcon: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setBackgroundImage(UIImage(named: "close"), for: .normal)
        btn.addTarget(self, action: #selector(justClose), for: .touchUpInside)
        return btn
    }()
    
    private lazy var ageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Age"
        label.font = Font.light.uiFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    private lazy var tagsAgeView: TagsView<Age> = {
        let tagsView = TagsView<Age>()
        tagsView.contentTags = Age.allCases
        tagsView.currentSelections = [Age.allCases.first?.rawValue ?? Age.small.rawValue]
        tagsView.equalSizeCount = 3
        tagsView.cellSize = CGSize(width:UIScreen.main.bounds.size.width*0.24, height:32)
        return tagsView
    }()
    
    private lazy var genderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Gender"
        label.font = Font.light.uiFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    private lazy var tagsGenderView: TagsView<Gender> = {
        let tagsView = TagsView<Gender>()
        tagsView.contentTags = Gender.allCases
        tagsView.currentSelections = [Gender.allCases.first?.rawValue ?? "Male"]
        tagsView.equalSizeCount = 3
        tagsView.cellSize = CGSize(width:UIScreen.main.bounds.size.width*0.24, height:32)
        return tagsView
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Dates"
        label.font = Font.light.uiFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    private lazy var departureView: DateView = {
        let vw = DateView(tite: "Departure", img: UIImage(named: "depart") ?? .init(), selected: true)
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.addTapGesture(target: self, selector: #selector(dateChanged(_:)))
        return vw
    }()
    
    private lazy var arrivalView: DateView = {
        let vw = DateView(tite: "Arrival", img: UIImage(named: "arrival") ?? .init(), selected: false)
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.addTapGesture(target: self, selector: #selector(dateChanged(_:)))
        return vw
    }()
    
    lazy var filterButton: PrimaryButton = {
        let btn = PrimaryButton()
        btn.setTitle("Filter", for: .normal)
        btn.addTarget(self, action: #selector(filterClicked), for: .touchUpInside)
        btn.layer.cornerRadius = 32
        btn.setBackgroundColor(Color.green.uiColor, forState: .normal)
        return btn
    }()
    
    lazy var resetButton: PrimaryButton = {
        let btn = PrimaryButton()
        btn.setTitle("Reset", for: .normal)
        btn.addTarget(self, action: #selector(resetClicked), for: .touchUpInside)
        btn.layer.cornerRadius = 32
        btn.setBackgroundColor(Color.red.uiColor, forState: .normal)
        return btn
    }()
    
    override func configure() {
        super.configure()
        self.layout()
    }
    
    override func didAppear() {
        super.didAppear()
        self.showTooltipOnce()
    }
    
    private func layout(){
        self.view.addSubview(searchContainer)
        searchContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(64)
        }
        
        searchContainer.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.leading.equalTo(16)
            make.width.equalTo(24)
            make.height.equalTo(searchIcon.snp.width).multipliedBy(1)
            
        }
        
        searchContainer.addSubview(closeIcon)
        closeIcon.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.trailing.equalTo(-16)
            make.width.equalTo(24)
            make.height.equalTo(closeIcon.snp.width).multipliedBy(1)
        }
        
        searchContainer.addSubview(locationResetIcon)
        locationResetIcon.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.trailing.equalTo(closeIcon.snp.leading).offset(-16)
            make.width.equalTo(24)
            make.height.equalTo(locationResetIcon.snp.width).multipliedBy(1)
        }
        
        searchContainer.addSubview(searchLabel)
        searchLabel.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon.snp.trailing).offset(16)
            make.centerY.equalTo(searchIcon)
            make.trailing.equalTo(locationResetIcon.snp.leading).offset(-16)
        }
        
        self.view.addSubview(ageLabel)
        ageLabel.snp.makeConstraints { make in
            make.leading.equalTo(24)
            make.top.equalTo(searchContainer.snp.bottom).offset(48)
        }
        
        self.view.addSubview(tagsAgeView)
        tagsAgeView.snp.makeConstraints { make in
            make.top.equalTo(ageLabel.snp.bottom).offset(16)
            make.leading.equalTo(24)
            make.trailing.equalTo(-24)
            make.height.equalTo(48)
        }
        
        self.view.addSubview(genderLabel)
        genderLabel.snp.makeConstraints { make in
            make.leading.equalTo(24)
            make.top.equalTo(tagsAgeView.snp.bottom).offset(48)
        }
        
        self.view.addSubview(tagsGenderView)
        tagsGenderView.snp.makeConstraints { make in
            make.top.equalTo(genderLabel.snp.bottom).offset(16)
            make.leading.equalTo(genderLabel)
            make.trailing.equalTo(-24)
            make.height.equalTo(48)
        }
        
        self.view.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(24)
            make.top.equalTo(tagsGenderView.snp.bottom).offset(48)
        }
        
        self.view.addSubview(departureView)
        departureView.snp.makeConstraints { make in
            make.leading.equalTo(24)
            make.width.equalToSuperview().multipliedBy(0.38)
            make.height.equalToSuperview().multipliedBy(0.14)
            make.top.equalTo(dateLabel.snp.bottom).offset(16)
        }
        
        self.view.addSubview(arrivalView)
        arrivalView.snp.makeConstraints { make in
            make.trailing.equalTo(-24)
            make.width.equalTo(departureView)
            make.height.equalTo(departureView)
            make.top.equalTo(dateLabel.snp.bottom).offset(16)
        }
        
        self.view.addSubview(resetButton)
        resetButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            $0.left.equalToSuperview().inset(32)
            $0.right.equalToSuperview().inset(32)
            $0.height.equalTo(64)
        }
        
        self.view.addSubview(filterButton)
        filterButton.snp.makeConstraints {
            $0.bottom.equalTo(resetButton.snp.top).offset(-16)
            $0.left.equalToSuperview().inset(32)
            $0.right.equalToSuperview().inset(32)
            $0.height.equalTo(64)
        }


    }
    
    @objc func navigateToPlaces(){
        let places = PlacesController()
        places.delegate = self.presenter
        self.present(places, animated: false, completion: nil)
    }
    
    @objc private func justClose(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func resetLocation(){
        self.presenter.resetLocation()
        setLocationDefault()
    }
    
    @objc private func close(){
        self.dismiss(animated: true, completion: nil)
        main(block: {
            self.delegate?.tripSearchControllerWillSearch()
        }, after: 0.5)
    }
    
    @objc func dateChanged(_ tapRecognizer: UITapGestureRecognizer){
        if let vw = tapRecognizer.view as? DateView {
            self.loadFullnameEditMode(source: vw)
        }
    }
    
    private func loadFullnameEditMode(source: DateView) {
        let controller = OnKbdEditorViewController
            .createModule(text: source.title.text,
                          viewTitle: source.title.text ?? "",
                          inputTitle: source.getKey.rawValue,
                          placeholder: source.getKey.rawValue,
                          customKey: source.getKey.rawValue,
                          delegate: self)
        controller.inputKind = source.getKey.inputKind
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc private func filterClicked(){
        
        guard let ageValue = self.tagsAgeView.currentSelections.last else { return }
        let age = Age(rawValue: ageValue as! String)
        
        guard let genderValue = self.tagsGenderView.currentSelections.last else { return }
        let gender = Gender(rawValue: genderValue as! String)
        
        let startDate = self.departureView.getDate
        let endDate = self.arrivalView.getDate

        self.presenter.save(age: age, gender: gender, startDate: startDate, endDate: endDate)
        
        self.close()
        
    }
    
    @objc private func resetClicked(){
        self.presenter.reset()
        self.setDefaultValue()
        self.view.makeToast("Success! Reset Filters is done! \n Trips will be refreshed!",position: .top)
    }
    
    private func setLocationDefault(){
        self.searchLabel.text = "Type city name..."
        self.locationResetIcon.isHidden = true
    }
    
    private func setDefaultValue(){
        setLocationDefault()
        self.tagsAgeView.currentSelections = [Age.small.rawValue]
        self.tagsGenderView.currentSelections = [Gender.male.rawValue]
        self.departureView.setDate(date: Date())
        self.arrivalView.setDate(date: Date())
    }
    
    private func showTooltipOnce(){
        if StandardUserDefaults.resetKeyHere == false {
            displayTooltip()
            StandardUserDefaults.resetKeyHere = true
        }
       
    }
    
    private func displayTooltip(){
        let popTip = PopTip()
        popTip.shouldShowMask = true
        popTip.shouldDismissOnTap = true
        popTip.shouldDismissOnTapOutside = true
        popTip.bubbleColor = Color.purple.uiColor
        popTip.show(text: "It will reset the applied filters and trips will get refreshed after resetting this...",
                    direction: .auto,
                    maxWidth: 300,
                    in: view,
                    from: resetButton.frame,
                    duration: 10)
        
        popTip.entranceAnimationHandler = { completion in
            popTip.transform = CGAffineTransform(rotationAngle: 0.3)
            UIView.animate(withDuration: 0.5, animations: {
                popTip.transform = .identity
            }, completion: { (_) in
                completion()
            })
        }
    }
}

extension TripSearchController: OnKbdEditorViewControllerDelegate {
    func onDone(with text: String?, pickerValue: String?, dateValue: __int64_t, customKey: String?) {
        let vw = [departureView,arrivalView].filter({$0.getKey.rawValue == customKey}).first
        vw?.setDate(date: dateValue.toDate)
    }
}

extension TripSearchController: TripSearchView {
    func updateView(age: Age?, gender: Gender?, startDate: Int64?, endDate: Int64?) {
        self.tagsAgeView.currentSelections = [age?.rawValue ?? Age.small.rawValue]
        self.tagsGenderView.currentSelections = [gender?.rawValue ?? Gender.male.rawValue]
        if let start = startDate, start != 0 {
            self.departureView.setDate(date: start.toDate)
        }
        if let end = endDate, endDate != 0 {
            self.arrivalView.setDate(date: end.toDate)
        }
    }
    
    func updateLocation(text: String?) {
        self.searchLabel.text = text
        self.locationResetIcon.isHidden = false
    }
}
