//
//  BasePresenter.swift
//  cario
//
//  Created by Irakli Vashakidze on 3/31/19.
//  Copyright © 2019 Cario. All rights reserved.
//

import Foundation

protocol BasePresenterView: AnyObject {
    func notifyError(message: String, okAction: (() -> Void)?)
    func reloadView()
    func willAppear()
    func willDisappear()
}

protocol Presenter: AnyObject {
    func attach(this view: BasePresenterView)
    func isLoggedIn() -> Bool
    func willAppear()
    func willDisappear()
    func detach()
}

class BasePresenter<View> : NSObject, Presenter {
    
    private var firstLaunch = true
    weak var baseView: BasePresenterView?
    
    var view : View? {
        return self.baseView as? View
    }
    
    private(set) var auth: UserService!
    
    init(auth: UserService) {
        super.init()
        self.auth = auth
    }
    
    override init() {
        super.init()
        self.auth = Service.auth
    }
    
    func attach(this view: BasePresenterView) {
        self.baseView = view
        
        if firstLaunch {
            firstLaunch = false
            onFirstViewAttach()
        }
    }
    
    func detach() {
        self.baseView = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    func onFirstViewAttach() { }
    
    func willAppear() {
        self.baseView?.willAppear()
    }
    
    func willDisappear() {
        self.baseView?.willDisappear()
    }
    
    func handleResponse<T: Any>(response: Result<T, Error>,
                                preReloadHandler:(()->Void)? = nil,
                                postReloadHandler:(()->Void)? = nil,
                                errorHandler:((Error)->Void)? = nil,
                                reload: Bool = true) {
        main {

            switch response {
            case .success(_):
                preReloadHandler?()
                if reload { self.baseView?.reloadView()  }
                postReloadHandler?()
                break
            case .failure(let error):
                self.baseView?.notifyError(message: error.message, okAction: nil)
                errorHandler?(error)
            }
        }
    }

    func isLoggedIn() -> Bool {
        return currentUserKey != nil
    }

    var currentUserKey : String? {
        return User.current?.uid
    }
}

