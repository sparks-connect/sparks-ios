//
//  EditProfileViewController.swift
//  Sparks
//
//  Created by George Vashakidze on 6/6/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import UIKit
import RxSwift
import SDWebImage

fileprivate enum EditKey: String {
    case name = "Name"
    case gender = "Gender"
    case birthDate = "Birth Date"
    case tags = "Interests"
    
    var inputKind: OnKbdEditorInputKind {
        switch self {
        case .gender: return .multi
        case .birthDate: return .date
        default: return .text
        }
    }
}

class EditProfileViewController: BaseController {

    let presenter = UserProPresenter()
    
    override func getPresenter() -> Presenter {
        return self.presenter
    }
    
    private lazy var cropper: ImageCropperUtil = {
        let cropper = ImageCropperUtil(viewController: self)
        cropper.delegate = self
        return cropper
    }()
    
    lazy private var listView : ListView = {
        let view = ListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func configure() {
        super.configure()
        self.navigationItem.title = "Edit Profile"
        configureLayout()
        setupListView()
    }
    
    private func configureLayout() {
        
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupListView(){
        listView.separatorStyle = .none
        listView.backgroundColor = .clear
        listView.separatorInset  = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        listView.cellClassIdentifiers = ["UserProfileCell": UserProfileCell.self]
        listView.cellReuseIdentifier = {
            (indexPath) in
            return "UserProfileCell"
        }
        listView.heightForRow = {(indexPath) in
            return 86
        }
        listView.sectionCount = ({ return 1 })
        listView.numberOfRows = {[weak self](section) in
            return self?.presenter.numberOfItems ?? 0
        }
        listView.cellDelegate = {(indexPath) in return self }
        listView.parameterForRow = {[weak self](indexPath) in
            return self?.presenter.settingsItem(atIndexPath: indexPath)
        }
        listView.didSelectRow = {[weak self](indexPath) in
            main {
                guard let settingsItem = self?.presenter.settingsItem(atIndexPath: indexPath) else { return }
                switch settingsItem.type {
                case .birthDate:
                    guard let mlsc = User.current?.birthDate else { return }
                    self?.loadFullnameEditMode(type: .birthDate, value: mlsc.toDate.toString())
                case .gender:
                    guard let gender = User.current?.genderEnum else { return }
                    self?.loadFullnameEditMode(type: .gender, value: gender.rawValue)
                case .firstName:
                    guard let firstName = User.current?.firstName else { return }
                    self?.loadFullnameEditMode(type: .name, value: firstName)
                case .tags:
                    self?.present(ProfileTagsController(), animated: true, completion: nil)
                default:
                    break
                }
            }
        }
    }
    
    private func loadFullnameEditMode(type: EditKey, value: String) {
        let controller = OnKbdEditorViewController
            .createModule(text: value,
                          viewTitle: "Edit Profile",
                          inputTitle: type.rawValue,
                          placeholder: type.rawValue,
                          customKey: type.rawValue,
                          delegate: self)
        controller.inputKind = type.inputKind
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    private func loadBirthdateEditMode(mlsc: Int64) {
        let controller = BirthDateController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func loadGenderEditMode(gender: Gender) {
        let controller = GenderController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func reloadView() {
        super.reloadView()
        self.listView.reloadData()
    }
}

extension EditProfileViewController: UserProfileView, TableViewCellDelegate, OnKbdEditorViewControllerDelegate {
 
    func updateSection(_ section: Int, deletions: [Int], insertions: [Int], modifications: [Int]) {
        listView.updateSection(0, with: .automatic, deletions: deletions, insertions: insertions, modifications: modifications)
    }
    
    func onDone(with text: String?, pickerValue: String?, dateValue: __int64_t, customKey: String?) {
        
        guard let key = customKey else { return }
        let kind = EditKey(rawValue: key) ?? .name

        switch kind {
        case .name:
            self.presenter.updateFirstname(text ?? "")
            break
        case .gender:
            guard let gen = Gender(rawValue: pickerValue ?? "") else { return }
            self.presenter.updateGender(gen)
            break
        case .birthDate:
            self.presenter.updateBirthdate(dateValue)
            break
        default:
            break
        }
    }
    
    func onKbEditorPickerDataSource() -> [String] {
        return Gender.list.map({ $0.rawValue })
    }
    
    func onKbEditorSelectedPickerIndex() -> Int {
        guard let u = User.current, let gender = u.genderEnum else { return 0 }
        return Gender.list.firstIndex(of: gender) ?? 0
    }
    
    func onKbEditorDateValue() -> Int64 {
        return User.current?.birthDate ?? 0
    }
}

extension EditProfileViewController: UserProfileImageCellDelegate, ImageCropperUtilDelegate, MainHeaderViewDelegate {
    
    func didCropImage(image: UIImage) {
        self.presenter.uploadImage(image: image)
    }
    
    func didTapAtIndex(_ index: Int) {
        self.presenter.imageIndex = index
        self.cropper.showImagePicker(otherActions: [], title: "Crop photo")
    }
    
    func needsImageRefresh() -> Bool {
        return false
    }
    
    func didTapOnActionButton() {
        self.navigationController?.popViewController(animated: true)
    }
}


