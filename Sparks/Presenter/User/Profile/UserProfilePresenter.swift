//
//  UserProfilePresenter.swift
//  Sparks
//
//  Created by George Vashakidze on 6/6/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import RealmSwift

protocol UserProfileView: BasePresenterView {    
}

enum UserProfileItemType {
    case firstName
    case birthDate
    case gender
    case facebook
    case instagram
    case tags
}

enum UserProfileItemStyle: Int {
    case style1
    case style2
    
    var style: UserProfileItemStyleAlias {
        let semiWhiteColor = Color.lightPurple.uiColor
        let titleColor: UIColor = self == .style1 ? semiWhiteColor : .white
        let subTitleColor: UIColor = self == .style1 ? .white : semiWhiteColor
        let titleFont = self == .style1 ? Font.medium.uiFont(ofSize: 14) : Font.bold.uiFont(ofSize: 16)
        let subTitleFont = self == .style1 ? Font.bold.uiFont(ofSize: 16) : Font.medium.uiFont(ofSize: 14)
        return (
            titleColor: titleColor,
            subTitleColor: subTitleColor,
            titleFont: titleFont,
            subTitleFont: subTitleFont
        )
    }
}

typealias UserProfileItemStyleAlias = (
    titleColor: UIColor,
    subTitleColor: UIColor,
    titleFont: UIFont,
    subTitleFont: UIFont
)

struct UserProfileItem: TableViewCellParameter {
    let image: String?
    let title: String
    let subTitle: String?
    let style: UserProfileItemStyle
    let type: UserProfileItemType
    
    func settingItemImage() -> UIImage? {
        guard let imageStr = image else { return nil }
        return UIImage(named: imageStr)
    }
}

struct UserProfileGalleryItem: TableViewCellParameter {
    let image1: String = "profileimage0.jpg"
    let image2: String = "profileimage1.jpg"
    let image3: String = "profileimage2.jpg"
}

class UserProPresenter: BasePresenter<UserProfileView> {
    
    private var datasource = [UserProfileItem]()
    var imageIndex: Int = 0
    private var tagsDatasource: [String: ProfileTag] = [:]
    private var token: NotificationToken?
    
    var numberOfItems: Int {
        return datasource.count
    }
    
    override init() {
        super.init()
        fetchTags()
    }

    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        token = RealmUtils.observeUserUpdates {
            self.initDatasource()
        }
    }
    
    private func fetchTags() {
        let results = RealmUtils.fetch(ProfileTag.self)
        results.forEach { tag in
            self.tagsDatasource[tag.uid] = tag
        }
    }
    
    func settingsItem(atIndexPath indexPath: IndexPath) -> UserProfileItem? {
        guard indexPath.row < datasource.count else { return nil }
        return datasource[indexPath.row]
    }
    
    func initDatasource() {
        self.datasource.removeAll()
        self.datasource.append(
            .init(image: "ic_profile_info", title: "Name", subTitle: User.current?.firstName, style: .style2, type: .firstName)
        )
        
        var userDate: String? = nil
        if let mlscs = User.current?.birthDate {
            let date = Date(milliseconds: mlscs)
            
            let df = DateFormatter()
            userDate = df.customFormattedString(from: date)
        }
        
        self.datasource.append(
            .init(image: nil, title: "Birth Date", subTitle: userDate, style: .style2, type: .birthDate)
        )
        
        self.datasource.append(
            .init(image: nil, title: "Gender", subTitle: User.current?.gender, style: .style2, type: .gender)
        )
        
        self.datasource.append(
            .init(image: nil,
                  title: "Interests",
                  subTitle: User.current?.tagsStr,
                  style: .style2, type: .tags)
        )
//
//        self.datasource.append(
//            .init(image: "ic_profile_facebook", title: "Facebook", subTitle: "Not Linked", style: .style2, type: .facebook)
//        )
//
//        self.datasource.append(
//            .init(image: "ic_profile_instagram", title: "Instagram", subTitle: "Not Linked", style: .style2, type: .instagram)
//        )
        
        self.view?.reloadView()
    }
    
    func updateFirstname(_ value: String) {
        self.auth.updateFirstname(value) {[weak self] (response) in
            self?.handleResponse(response: response, preReloadHandler: {
                self?.initDatasource()
            })
        }
    }
    
    func updateBirthdate(_ value: Int64) {
        self.auth.updateBirthDate(value) { [weak self] (response) in
            self?.handleResponse(response: response, preReloadHandler: {
                self?.initDatasource()
            })
        }
    }
    
    func updateGender(_ value: Gender) {
        self.auth.updateGender(value) {[weak self] (response) in
            self?.handleResponse(response: response, preReloadHandler: {
                self?.initDatasource()
            })
        }
    }
    
    func uploadImage(image: UIImage) {
        guard let data = image.compressed else { return }
        self.auth.updatePhoto(data: data, main: imageIndex == 0) { [weak self] (response) in
            self?.handleResponse(response: response)
        }
    }
    
    deinit {
        token?.invalidate()
    }
}
