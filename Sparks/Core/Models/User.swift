//
//  User.swift
//  AnimalForestChat
//
//  Created by Craig Lane on 4/1/19.
//

import UIKit
import Firebase
import MessageKit
import RealmSwift
import SDWebImage

enum Age: String, Codable, Tag {
    case small = "18-32"
    case mid = "32-50"
    case elder = "From 50"
    
    var range: ClosedRange<Int> {
        switch self {
        case .small: return 18...32
        case .mid: return 33...50
        case .elder: return 51...80
        }
    }
    
    func getLabel() -> String {
        return self.rawValue
    }
}

enum Gender: String, Codable, Tag {
    case male = "Male"
    case female = "Female"
    case both = "Both"
    
    static var list: [Gender] {
        [Gender.female, Gender.male, Gender.both]
    }
    
    func getLabel() -> String {
        return self.rawValue
    }
    
    var icon: UIImage? {
        switch self {
        case .both: return UIImage(named: "both")
        case .male: return UIImage(named: "male")
        case .female: return UIImage(named: "female")
        }
    }
}

struct UserConsts {
    static let kDynamicLinkKey = "kDynamicLinkKey"
}

class User: BaseModelObject, SenderType {
    
    enum CodingKeys: String, CodingKey {
        case firstName,
        lastName,
        email,
        phone,
        birthDate,
        gender,
        genderPreference,
        minAge,
        maxAge,
        distance,
        lat,
        lng,
        lastUpdated,
        token,
        deviceTokens,
        profileTags,
        instaID,
        instaToken,
        instaUserName,
        referrer = "referredBy",
        _photos = "photos",
        _favourites = "favourites"
    }
    
    /// First name
    @objc dynamic private(set) var firstName: String?
    /// Last (Family) name
    @objc dynamic private(set) var lastName: String?
    /// User email
    @objc dynamic private(set) var email: String?
    /// User email
    @objc dynamic private(set) var phone: String?
    /// User birth date
    @objc dynamic private(set) var birthDate: Int64 = 0
    /// User Gender
    @objc dynamic private(set) var gender: String?
    /// Gender Preference
    @objc dynamic private(set) var genderPreference: String?
    /// Minimum age for  filter
    @objc dynamic private(set) var minAge: Int = FirebaseConfigManager.shared.minAgePref
    /// Maximum age for filter
    @objc dynamic private(set) var maxAge: Int = FirebaseConfigManager.shared.maxAgePref
    /// Distance filter for search
    @objc dynamic private(set) var distance: Int = FirebaseConfigManager.shared.distancePref
    /// User's last known latitude
    @objc dynamic private(set) var lat: Double = 0
    /// User's last known longitude
    @objc dynamic private(set) var lng: Double = 0
    /// User's last known longitude
    @objc dynamic private(set) var lastUpdated: Double = 0
    /// Token
    @objc dynamic private(set) var token: String?
    /// Referrer
    @objc dynamic private(set) var referrer: String?
    /// insta user id
    @objc dynamic private(set) var instaID: Int64 = 0
    /// insta access token
    @objc dynamic private(set) var instaToken: String?
    /// insta user Name
    @objc dynamic private(set) var instaUserName: String?

    
    private var _profileTags: [String]?
    private var _deviceTokens: [String]?
    
    private var _photos: [UserPhoto]?
    private var _favourites: [Trip]?
    
    let photos = List<UserPhoto>()
    let favourites = List<Trip>()
    
    var dynamicLink: String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: UserConsts.kDynamicLinkKey)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: UserConsts.kDynamicLinkKey)
        }
    }
    
    /// User who requested share
    let deviceTokens = List<String>()
    let profileTags = List<String>()
    
    var deviceTokensArr: [String] {
        var res = [String]()
        deviceTokens.forEach { (token) in
            res.append(token)
        }
        return res
    }
    
    /// isLogged
    @objc dynamic var loggedIn: Bool = false {
        didSet {
            if self.loggedIn == false {
                self.token = nil
            }
        }
    }
    
    init(uid: String) {
        super.init()
        self.uid = uid
    }
    
    init(uid: String, firstName: String?, lastName: String?) {
        super.init()
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
    }
    
    func update(_ user: User) {
        self.firstName = user.firstName
        self.birthDate = user.birthDate
        self.gender = user.gender
        self._deviceTokens = user._deviceTokens
        self._profileTags = user._profileTags
        self._photos = user._photos
        self._favourites = user._favourites
        self.convertPhotos()
        self.convertToken()
        self.convertTags()
        self.convertFavourites()
    }
    
    private func convertPhotos() {
        self.photos.forEach { photo in
            self.realm?.delete(photo)
        }
        self.photos.removeAll()
        self._photos?.forEach { (photo) in
            self.photos.append(photo)
        }
    }
    
    private func convertToken() {
        self.deviceTokens.removeAll()
        self._deviceTokens?.forEach({ (token) in
            self.deviceTokens.append(token)
        })
    }
    
    private func convertTags() {
        self.profileTags.removeAll()
        self._profileTags?.forEach({ (token) in
            self.profileTags.append(token)
        })
    }
    
    private func convertFavourites() {
        self.favourites.removeAll()
        self._favourites?.forEach({ (token) in
            self.favourites.append(token)
        })
    }
    
    func getFavourites() -> [Trip] {
        return self._favourites ?? []
    }
    
    required override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.gender = try container.decodeIfPresent(String.self, forKey: .gender)
        self.genderPreference = try container.decodeIfPresent(String.self, forKey: .genderPreference) ?? Gender.both.rawValue
        self.minAge = try container.decodeIfPresent(Int.self, forKey: .minAge) ?? 0
        self.maxAge = try container.decodeIfPresent(Int.self, forKey: .maxAge) ?? 0
        self.distance = try container.decodeIfPresent(Int.self, forKey: .distance) ?? 0
        self.lat = try container.decodeIfPresent(Double.self, forKey: CodingKeys.lat) ?? 0
        self.lng = try container.decodeIfPresent(Double.self, forKey: CodingKeys.lng) ?? 0
        self.lastUpdated = try container.decodeIfPresent(Double.self, forKey: CodingKeys.lastUpdated) ?? 0
        self.birthDate = try container.decodeIfPresent(Int64.self, forKey: CodingKeys.birthDate) ?? 0
        self.instaID = try container.decodeIfPresent(Int64.self, forKey: CodingKeys.instaID) ?? 0
        self.instaToken = try container.decodeIfPresent(String.self, forKey: CodingKeys.instaToken)
        self.instaUserName = try container.decodeIfPresent(String.self, forKey: CodingKeys.instaUserName)
        self._profileTags = try container.decodeIfPresent([String]?.self, forKey: .profileTags) ?? nil
        self._deviceTokens = try container.decodeIfPresent([String]?.self, forKey: .deviceTokens) ?? nil
        self._photos = try container.decodeIfPresent([UserPhoto]?.self, forKey: ._photos) ?? []
        self._favourites = try container.decodeIfPresent([Trip]?.self, forKey: ._favourites) ?? []
        
        self.convertTags()
        self.convertToken()
        self.convertPhotos()
        self.convertFavourites()
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
}

extension User {
    
    static let kPath = "users"
    
    var photoUrl: String {
        return self.photos.first(where: { $0.main == true })?.url ?? ""
    }
    
    var photoGallery: [URL] {
        self.photos.map({ URL(string: $0.url!)! })
    }
    
    var otherUrls: [String] {
        let arr: [UserPhoto] = self.photos.filter({ $0.main == false })
        return arr.map({ $0.url! })
    }
    
    var genderEnum: Gender? {
        guard let gender = self.gender else {
            return nil
        }
        
        return Gender(rawValue: gender)
    }
    
    var genderPreferenceEnum: Gender? {
        guard let gender = self.genderPreference else {
            return nil
        }
        
        return Gender(rawValue: gender)
    }
    
    var ageYear: Int {
        return Date().year - self.birthDate.toDate.year
    }
    
    static var current: User? {
        do {
            let realm = try Realm()
            realm.refresh()
            return realm.objects(User.self).first(where: { $0.loggedIn == true })
            
        } catch {
            print(error)
        }
        return nil
    }
    
    var balance: UserBalance? {
        do {
            let realm = try Realm()
            realm.refresh()
            return realm.objects(UserBalance.self).first(where: { $0.uid == self.uid })
            
        } catch {
            print(error)
        }
        return nil
    }
    
    var hasFreeBalance: Bool {
        guard let bal = self.balance else { return false }
        return (bal.freeBalance + bal.referBalance) > 0
    }
    
    static var isLoggedIn: Bool {
        return current != nil
    }
    
    // The display name of the user
    public var displayName: String {
        return "\(firstName?.trimmingCharacters(in: .whitespaces) ?? "")"
    }
    
    public var fullName: String {
        return "\(firstName ?? "") \(lastName ?? "")"
    }
    
    public var senderId: String {
        return uid
    }
    
    var isMissingRequredInfo: Bool {
        self.isMissingName || self.isMissingGender || self.isMissingBirthdate
    }
    
    static var hasSeenOnboarding: Bool {
        return LocalStore.hasSeenOnboarding
    }
    
    var isMissingName: Bool {
        self.firstName == nil || self.firstName?.isEmpty == true
    }
    
    var isMissingLocation: Bool {
        self.lat == 0.0 && self.lng == 0.0
    }
    
    var isMissingGender: Bool {
        self.gender == nil
    }
    
    var isMissingBirthdate: Bool {
        self.birthDate == 0
    }
    
    var isMissingPhoto: Bool {
        return self.photos.isEmpty
    }
    
    var isMissingInterests: Bool {
        return self.profileTags.isEmpty
    }
    
    var isMissingInstaToken: Bool {
        self.instaToken == nil || self.instaToken?.isEmpty == true
    }
    
    var tagsStr: String {
        
        guard !self.profileTags.isInvalidated else { return "" }
        
        var tags = ""
        var i = 0
        let count = self.profileTags.count
        
        self.profileTags.forEach({ str in
            let name = Service.tags.tag(forKey: str)?.name ?? ""
            tags.append(name + (i < count - 1 ? ", " : ""))
            i += 1
        })
        
        if tags.isEmpty {
            tags = "No interests selected 😞"
        }
        return tags
    }
    
    func isTripFavourite(uid: String) -> Bool {
        return self.favourites.contains(where: { $0.uid == uid })
    }
}

extension User {

    var path: String {
        return "\(User.kPath)/\(uid)"
    }

    var mergeFields: [String] {
        return [
            User.CodingKeys.firstName.rawValue,
            User.CodingKeys.lastName.rawValue,
            User.CodingKeys.gender.rawValue,
            User.CodingKeys.birthDate.rawValue
        ]
    }
    
    var photosMapArray: [[String: Any]] {
        let result: [[String: Any]] = self.photos.map({ $0.values })
        return result
    }
    
    var values: [String: Any] {
        
        let tokens: [String] = deviceTokens.map({ $0 })
        
        return [
            User.CodingKeys.firstName.rawValue: firstName ?? NSNull(),
            User.CodingKeys.lastName.rawValue: lastName ?? NSNull(),
            User.CodingKeys.gender.rawValue: gender ?? NSNull(),
            User.CodingKeys.birthDate.rawValue: birthDate,
            BaseModelObject.BaseCodingKeys.uid.rawValue: uid,
            User.CodingKeys._photos.rawValue: photosMapArray,
            User.CodingKeys.deviceTokens.rawValue: tokens
        ]
    }
}
