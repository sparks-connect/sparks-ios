//
//  FirestoreUtil.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 2/9/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFunctions
import FBSDKLoginKit
import GoogleSignIn
import FirebaseCrashlytics
import FirebaseMessaging

// ############ Service ##########################################

enum CompareType {
    case equals
    case lessThan
    case greaterThan
    case lessThanOrEqual
    case greaterThanOrEqual
    case arrayContains
    case pathEquals
}

typealias Predicate = (field: String, type: CompareType, value: Any)

/// Main interface for Http request manager
protocol FirebaseAPI: AnyObject {

    /// Firestore
    func fetchNode(at path: String, completion: @escaping (Result<[String: Any]?, Error>) -> Void)
    func fetchNode<T: Codable>(type: T.Type, at collection: String, uid: String, completion: @escaping (Result<T?, Error>) -> Void)
    func observe<T: Codable>(type: T.Type, at collection: String, uid: String, completion: @escaping (Result<T?, Error>) -> Void) -> String
    func fetchItems<T: Codable>(type: T.Type, at path: String, predicates: [Predicate], completion: @escaping (Result<[T], Error>) -> Void)
    func fetchItems<T: Codable>(type: T.Type,
                                at path: String,
                                predicates: [Predicate],
                                orderBy: [String]?,
                                desc: Bool?,
                                limit: Int?,
                                completion: @escaping (Result<[T], Error>) -> Void)
    func observeItems<T: Codable>(type: T.Type, at path: String, predicates: [Predicate], completion: @escaping (Result<[T], Error>) -> Void) -> String
    func setNode(path: String, values: [String: Any], mergeFields fields:[Any]?, completion: @escaping (Result<Any?, Error>) -> Void)
    func addNode(path: String, values: [String: Any], completion: @escaping (Result<String?, Error>) -> Void)
    func updateNode(path: String, values: [String: Any], completion: ((Result<Any?, Error>) -> Void)?)
    func arrayUnion(_ elements: [Any]) -> Any
    func removeListener(forKey key: String?)
    func deleteNode(path: String, completion: @escaping (Result<Any?, Error>) -> Void)
    
    /// Auth
    func fbAuth(controller: UIViewController, completion: @escaping (Result<Any?, Error>) -> Void)
    func appleAuth(controller: UIViewController, completion: @escaping (Result<Any?, Error>) -> Void)
    func googleAuth(controller: UIViewController, completion: @escaping (Result<Any?, Error>) -> Void)
    func verifyPhoneNumber(_ phoneNumber: String, completion:@escaping(_ response: Result<String, Error>) -> Void)
    func signIn(verificationID: String, verificationCode: String, completion:@escaping(_ response: Result<Any?, Error>) -> Void)
    
    func logOut()

    /// Functions
    func acceptChannel(_ channelId: String, completion: @escaping (Result<ChannelStateUpdateResponse, Error>) -> Void)
    func rejectChannel(_ channelId: String, completion: @escaping (Result<ChannelStateUpdateResponse, Error>) -> Void)
    func shareChannel(_ channelId: String, completion: @escaping (Result<ChannelStateUpdateResponse, Error>) -> Void)
    func updateToken(_ token: String, completion: @escaping (Result<Any?, Error>) -> Void)
    var serverTimestamp: Any { get }
    
    func callFunction<T: Codable>(type: T.Type, functionName: String, params: [String: Any], completion: @escaping (Result<T, Error>) -> Void)
}

fileprivate typealias GoogleSignInResult = (Result<Any?, Error>) -> Void
fileprivate typealias AppleSignInResult = (Result<Any?, Error>) -> Void

/// Provides easy wrapped access to Firestore API
class FirebaseAPIImpl: NSObject, FirebaseAPI {
 
    private let database = Firestore.firestore()
    private lazy var listeners = [String : ListenerRegistration]()
    private var userObserveIdent: String?
    private var balanceObserveIdent: String?
    private let functions = Functions.functions()
    private var googleSignInResult: GoogleSignInResult?
    private var appleSignInResult: AppleSignInResult?

    static func setup() {
        FirebaseApp.configure()
        #if DEBUG
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        #endif
        FirebaseConfigManager.shared.refetch({ _ in })
    }

    override init() {
        super.init()
        let settings = Firestore.firestore().settings
        settings.isPersistenceEnabled = false
        Firestore.firestore().settings = settings
//        GIDSignIn.sharedInstance().delegate = self
//        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
//
        self.observeUser()
    }

    private func addListener(_ listener: ListenerRegistration) -> String {
        let uid = UUID().uuidString
        self.listeners[uid] = listener
        return uid
    }

    func removeListener(forKey key: String?) {
        guard let key = key else { return }
        self.listeners[key]?.remove()
        self.listeners.removeValue(forKey: key)
    }

    private func getQueryObj(for ref: Query, predicate: Predicate) -> Query {
        switch predicate.type {
        case .equals:
            return ref.whereField(predicate.field, isEqualTo: predicate.value)
        case .lessThan:
            return ref.whereField(predicate.field, isLessThan: predicate.value)
        case .greaterThan:
            return ref.whereField(predicate.field, isGreaterThan: predicate.value)
        case .lessThanOrEqual:
            return ref.whereField(predicate.field, isLessThanOrEqualTo: predicate.value)
        case .greaterThanOrEqual:
            return ref.whereField(predicate.field, isGreaterThanOrEqualTo: predicate.value)
        case .arrayContains:
            return ref.whereField(predicate.field, arrayContains: predicate.value)
        case .pathEquals:
            return ref.whereField(predicate.field, isEqualTo: predicate.value)
        }
    }

    func fetchNode(at path: String, completion: @escaping (Result<[String: Any]?, Error>) -> Void) {
        database.document(path).getDocument(source: .default) { (snap, error) in
            if let e = error {
                completion(.failure(e))
            } else {
                completion(.success(snap?.data()))
            }
        }
    }
    
    func fetchNode<T: Codable>(type: T.Type, at collection: String, uid: String, completion: @escaping (Result<T?, Error>) -> Void) {
        database.document("\(collection)/\(uid)").getDocument(source: .default) { (snap, error) in
            if let e = error {
                completion(.failure(e))
            } else if var data = snap?.data() {
                data[BaseModelObject.BaseCodingKeys.uid.rawValue] = uid
                if let timestamp = data[User.CodingKeys.lastUpdated.rawValue] as? Timestamp {
                    data[User.CodingKeys.lastUpdated.rawValue] = Double(timestamp.seconds * 1000) + Double(timestamp.nanoseconds) / Double(1000000)
                }
                
                let enc = JSONDecoder.decode(T.self, from: data)
                completion(.success(enc))
                
            } else {
                completion(.success(nil))
            }
        }
    }

    func observe<T: Codable>(type: T.Type, at collection: String, uid: String, completion: @escaping (Result<T?, Error>) -> Void) -> String {
        let reg = database.document("\(collection)/\(uid)").addSnapshotListener { (snap, error) in
            if let e = error {
                completion(.failure(e))
            } else if var data = snap?.data() {
                data[BaseModelObject.BaseCodingKeys.uid.rawValue] = uid
                let enc = JSONDecoder.decode(T.self, from: data)
                completion(.success(enc))
                
            } else {
                completion(.success(nil))
            }
        }
        return addListener(reg)
    }

    func goOffline() {
        self.database.disableNetwork(completion: nil)
    }

    func goOnline() {
        self.database.enableNetwork(completion: nil)
    }

    func timeStamp(from millis: Double) -> Any {
        return Timestamp(seconds: Int64(millis/1000), nanoseconds: 0)
    }

    func fetchItems<T: Codable>(type: T.Type, at path: String, predicates: [Predicate], completion: @escaping (Result<[T], Error>) -> Void) {
        fetchItems(type: type, at: path, predicates: predicates, orderBy: nil, desc: nil, limit: nil, completion: completion)
    }
    
    func fetchItems<T: Codable>(type: T.Type,
                                at path: String,
                                predicates: [Predicate],
                                orderBy: [String]?,
                                desc: Bool?,
                                limit: Int?,
                                completion: @escaping (Result<[T], Error>) -> Void) {

        var ref: Query!
        if let order = orderBy {
            
            ref = database.collection(path)
            order.forEach { ord in
                ref = ref.order(by: ord, descending: desc ?? false)
            }
            
        } else {
            ref = database.collection(path)
        }
        
        if let limit = limit {
            ref = ref.limit(to: limit)
        }
        
        if predicates.isEmpty {
            
            ref.getDocuments { [weak self] (snap, error) in
                self?.process(snap: snap, error: error, completion: completion)
            }
        } else {
            
            predicates.forEach { predicate in
                ref = self.getQueryObj(for: ref, predicate: predicate)
            }

            ref.getDocuments { [weak self] (snap, error) in
                self?.process(snap: snap, error: error, completion: completion)
            }
        }
    }

    func observeItems<T: Codable>(type: T.Type, at path: String, predicates: [Predicate], completion: @escaping (Result<[T], Error>) -> Void) -> String {

        let ref = database.collection(path)

        if predicates.isEmpty {
            let reg = ref.addSnapshotListener({ [weak self] (snap, error) in
                self?.process(snap: snap, error: error, completion: completion)
            })
            return self.addListener(reg)
        } else {
            var query: Query!
            predicates.forEach { predicate in
                query = self.getQueryObj(for: query ?? ref, predicate: predicate)
            }

            let reg = query.addSnapshotListener { [weak self] (snap, error) in
                self?.process(snap: snap, error: error, completion: completion)
            }
            return self.addListener(reg)
        }
    }

    func setNode(path: String, values: [String: Any], mergeFields fields:[Any]? = nil, completion: @escaping (Result<Any?, Error>) -> Void) {
        if let fields = fields {
            database.document(path).setData(values, mergeFields: fields) { (error) in
                if let e = error {
                    completion(.failure(e))
                } else {
                    completion(.success(nil))
                }
            }
        } else {
            database.document(path).setData(values) { (error) in
                if let e = error {
                    completion(.failure(e))
                } else {
                    completion(.success(nil))
                }
            }
        }
    }

    func addNode(path: String, values: [String: Any], completion: @escaping (Result<String?, Error>) -> Void) {
        var ref: DocumentReference?
        ref = database.collection(path).addDocument(data: values) { (error) in
            if let e = error {
                completion(.failure(e))
            } else {
                completion(.success(ref?.documentID))
            }
        }
    }

    func updateNode(path: String, values: [String: Any], completion: ((Result<Any?, Error>) -> Void)?) {
        database.document(path).setData(values, merge: true) { (error) in
            if let e = error {
                completion?(.failure(e))
            } else {
                completion?(.success(nil))
            }
        }
    }
    
    func deleteNode(path: String, completion: @escaping (Result<Any?, Error>) -> Void) {
        database.document(path).delete { error in
            if let e = error {
                completion(.failure(e))
            } else {
                completion(.success(nil))
            }
        }
    }
    
    private func process<T: Codable>(snap: QuerySnapshot?, error: Error?, completion: @escaping (Result<[T], Error>) -> Void) {
        if let e = error {
            completion(.failure(e))
        } else {
            var resp = [T]()
            for document in snap?.documents ?? [] {
             var doc = document.data()
                doc[BaseModelObject.BaseCodingKeys.uid.rawValue] = document.documentID
                guard let object = JSONDecoder.decode(T.self, from: doc) else { continue }
                resp.append(object)
            }
            completion(.success(resp))
        }
    }

    func arrayUnion(_ elements: [Any]) -> Any {
        return FieldValue.arrayUnion(elements)
    }

    var serverTimestamp: Any {
        return FieldValue.serverTimestamp()
    }
}

extension FirebaseAPIImpl {

    func fbAuth(controller: UIViewController, completion: @escaping (Result<Any?, Error>) -> Void) {

        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email"], from: controller) { (result, error) -> Void in
            
            guard let result = result, let token = result.token, error == nil else {
                completion(.failure(CIError.unauthorized))
                return
            }
            
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start { [weak self] con, result, error in
                guard let user = result as? [String: Any], error == nil else {
                    completion(.failure(CIError.unauthorized))
                    return
                }

                let credential = FacebookAuthProvider.credential(withAccessToken: token.tokenString)
                self?.fireAuth(credential, completion: completion)
            }
            
        }
    }
    
    private func clearFbPermissions() {
        GraphRequest.init(graphPath: "me/permissions/", httpMethod: .delete).start { (conn, result, error) in
            LoginManager().logOut()
        }
    }
    
    private func fireAuth(_ credential: AuthCredential,
                          completion: @escaping (Result<Any?, Error>) -> Void) {
        
        Auth.auth().signIn(with: credential) {[weak self] (authResult, error) in
            guard let u = authResult?.user else {
                completion(.failure(error ?? CIError.unauthorized))
                return
            }
            
            let name = u.displayName?.split(separator: " ")
            let firstName = String(name?.first ?? "")
            let lastName = String(name?.last ?? "")

            self?.fetchNode(type: User.self, at: User.kPath, uid: u.uid, completion: { (result) in
                switch result {
                case .success(let user):
                    if let _user = user {
                        _user.loggedIn = true
                        RealmUtils.save(object: _user)
                        self?.updateToken(Messaging.messaging().fcmToken ?? "", completion: { (_) in
                            self?.observeUser()
                            completion(.success(nil))
                        })
                    } else {
                        self?.saveUser(uid: u.uid,
                                       firstName: firstName,
                                       lastName: lastName,
                                       phoneNumber: u.phoneNumber ?? "",
                                       referrer: MemoryStore.sharedInstance.getValue(forKey: MemoryStore.MemoryKeys.userUid) as? String,
                                       completion: completion)
                    }
                    break
                case .failure(let error):
                    completion(.failure(error))
                    break
                }
            })
        }
    }
    
    func updateToken(_ token: String, completion: @escaping (Result<Any?, Error>) -> Void) {
        guard let user = User.current else {
            completion(.failure(CIError.unauthorized))
            return
        }
        
        var stringsArray = [String]()
        user.deviceTokens.forEach { (string) in
            stringsArray.append(string)
        }
        
        if !stringsArray.contains(token) {
            stringsArray.append(token)
        }
        
        self.updateNode(path: user.path, values: [User.CodingKeys.deviceTokens.rawValue: stringsArray], completion: completion)
    }
    
    private func saveUser(uid: String, firstName: String,
                          lastName: String,
                          phoneNumber: String,
                          referrer: String?,
                          completion: ((Result<Any?, Error>) -> Void)? = nil) {
        var nodeData: [String: Any] = [
            User.CodingKeys.firstName.rawValue: firstName,
            User.CodingKeys.lastName.rawValue: lastName,
            User.CodingKeys.phone.rawValue: phoneNumber,
            User.CodingKeys.distance.rawValue: FirebaseConfigManager.shared.distancePref,
            User.CodingKeys.genderPreference.rawValue: FirebaseConfigManager.shared.genderPref,
            User.CodingKeys.minAge.rawValue: FirebaseConfigManager.shared.minAgePref,
            User.CodingKeys.maxAge.rawValue: FirebaseConfigManager.shared.maxAgePref,
            User.CodingKeys.deviceTokens.rawValue: [Messaging.messaging().fcmToken ?? ""]
        ]
        
        if let referrer = referrer {
            nodeData[User.CodingKeys.referrer.rawValue] = referrer
        }
        
        self.updateNode(path: "users/\(uid)", values: nodeData, completion: {[weak self] (result) in
            switch result {
            case .failure(let error):
                completion?(.failure(error))
            case .success(_):
                let user = User(uid: uid, firstName: firstName, lastName: lastName)
                user.loggedIn = true
                RealmUtils.save(object: user)
                self?.observeUser()
                completion?(.success(nil))
            }
        })
    }
    
    func appleAuth(controller: UIViewController, completion: @escaping (Result<Any?, Error>) -> Void) {
        self.appleSignInResult = completion
    }

    func googleAuth(controller: UIViewController, completion: @escaping (Result<Any?, Error>) -> Void) {
        let signInConfig = GIDConfiguration.init(clientID: "640617421139-pfl53bockpnc74fv5t16jnc37fj996bb.apps.googleusercontent.com")
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: controller) { user, error in
            guard error == nil else { return }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            self.fireAuth(credential, completion: completion)
        }
    }
    
    private func observeUser() {
        
        guard let user = User.current,
                let u = Auth.auth().currentUser,
                    u.uid == user.uid,
                        userObserveIdent == nil else {
            self.logOut()
            return
        }
        
        if let uid = User.current?.uid { Crashlytics.crashlytics().setUserID(uid) }
        
        Auth.auth().currentUser?.getIDToken(completion: { (token, error) in
            debugPrint("TOKEN = ", token ?? "")
        })
        
        self.userObserveIdent = observe(type: User.self, at: User.kPath, uid: user.uid) {[weak self] (result) in
            switch result {
            case .success(let user):
                guard let u = user else {
                    self?.logOut()
                    AppDelegate.updateRootViewController()
                    return
                }
                u.loggedIn = true
                RealmUtils.save(object: u)
                
                DeepLinkHelper.generateLink(params: ["uid": u.uid, "name": u.displayName]) { (response) in
                    switch response {
                    case .success(let url):
                        u.dynamicLink = url
                        break
                    case .failure(let error):
                        debugPrint(error)
                    }
                }
                
            default: break
            }
        }
        
        self.observeBalance(uid: user.uid)
    }
    
    private func observeBalance(uid: String) {
        
        self.balanceObserveIdent = observe(type: UserBalance.self, at: UserBalance.kPath, uid:uid) { (result) in
            switch result {
            case .success(let balance):
                guard let balance = balance else { return }
                RealmUtils.save(object: balance)
            default: break
            }
        }
    }

    func logOut() {
        NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
        clearFbPermissions()
        RealmUtils.deleteAll()
        database.clearPersistence { (error) in
            if let error = error {
                print("Error clearing firestore cache: \(error)")
            }
        }
        try? Auth.auth().signOut()
        removeListener(forKey: userObserveIdent)
        removeListener(forKey: balanceObserveIdent)
        userObserveIdent = nil
        balanceObserveIdent = nil
    }
    
    func callFunction<T: Codable>(type: T.Type, functionName: String, params: [String: Any], completion: @escaping (Result<T, Error>) -> Void) {
        guard User.current != nil else {
            completion(.failure(CIError.unauthorized))
            return
        }
        
        functions.httpsCallable(functionName).call(params) { (result, error) in
            guard let res = result?.data as? [String: Any], error == nil,
                    let enc = JSONDecoder.decode(T.self, from: res) else {
                completion(.failure(error ?? CIError.unknown))
                return
            }
            
            completion(.success(enc))
        }
    }
    
    func acceptChannel(_ channelId: String, completion: @escaping (Result<ChannelStateUpdateResponse, Error>) -> Void) {
        self.updateChannel(Consts.Firebase.apiCall_acceptChannel, channelId, completion: completion)
    }
    
    func rejectChannel(_ channelId: String, completion: @escaping (Result<ChannelStateUpdateResponse, Error>) -> Void) {
        self.updateChannel(Consts.Firebase.apiCall_rejectChannel, channelId, completion: completion)
    }
    
    func shareChannel(_ channelId: String, completion: @escaping (Result<ChannelStateUpdateResponse, Error>) -> Void) {
        self.updateChannel(Consts.Firebase.apiCall_shareChannel, channelId, completion: completion)
    }
    
    private func updateChannel(_ apiCall: String, _ channelId: String, completion: @escaping (Result<ChannelStateUpdateResponse, Error>) -> Void) {
        
        functions.httpsCallable(apiCall).call(["channelId": channelId]) { (result, error) in
          
            guard let res = result?.data as? [String: Any], error == nil,
                    let enc = JSONDecoder.decode(ChannelStateUpdateResponse.self, from: res) else {
                completion(.failure(error ?? CIError.unknown))
                return
            }

            if enc.success {
                completion(.success(enc))
            } else {
                completion(.failure(enc.error ?? CIError.unknown))
            }
        }
    }
    
    func verifyPhoneNumber(_ phoneNumber: String, completion:@escaping(_ response: Result<String, Error>) -> Void) {
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            guard error == nil, let uid = verificationID else {
                completion(.failure(error ?? CIError.unknown))
                return
            }
            
            completion(.success(uid))
        }
    }
    
    func signIn(verificationID: String, verificationCode: String, completion:@escaping(_ response: Result<Any?, Error>) -> Void) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        self.fireAuth(credential, completion: completion)
    }
    
}

//extension FirebaseAPIImpl: GIDSignInDelegate {
//
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
//
//      guard let completion = self.googleSignInResult else { return }
//
//      if let error = error {
//        self.googleSignInResult?(.failure(error))
//        self.googleSignInResult = nil
//        return
//      }
//
//      guard let authentication = user.authentication else { return }
//      let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
//                                                        accessToken: authentication.accessToken)
//
//        var userData: [String: Any] = [User.CodingKeys.email.rawValue: user?.profile?.email ?? ""]
//        if let url = user.profile?.imageURL(withDimension: 256) {
//            userData["picture"] = ["data": ["url": url.absoluteString]]
//        }
//
//        fireAuth(credential,
//                 userData: userData,
//                 completion: completion)
//
//        self.googleSignInResult = nil
//    }
//
//    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
//        // Perform any operations when the user disconnects from app here.
//        // ...
//    }
//}
