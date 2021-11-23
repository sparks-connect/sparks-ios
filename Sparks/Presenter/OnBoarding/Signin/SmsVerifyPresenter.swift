//
//  SmsVerifyPresenter.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 7/20/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation

protocol SmsVerifyView: BasePresenterView {
    func didLoginSuccessfully()
}

class SmsVerifyPresenter: BasePresenter<SmsVerifyView> {
    
    private static let MAX_SECONDS: TimeInterval = 60
    
    var phone: String = ""
    var verificationID: String = ""
    
    private var timer: Timer?
    private var service = Service.auth
    private(set) var elapsed = SmsVerifyPresenter.MAX_SECONDS
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        rescheduleTimer()
    }
    
    private func rescheduleTimer() {
        self.elapsed = SmsVerifyPresenter.MAX_SECONDS
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {[weak self] (timer) in
            self?.elapsed -= 1
            self?.view?.reloadView()
            
            if self?.elapsed == 0 {
                self?.timer?.invalidate()
                self?.timer = nil
            }
        })
    }
    
    func signIn(code: String) {
        service.signIn(verificationID: self.verificationID, verificationCode: code) {[weak self] (response) in
            self?.handleResponse(response: response, preReloadHandler: {
                self?.view?.didLoginSuccessfully()
            }, reload: false)
        }
    }
    
    func resend() {
        service.verifyPhoneNumber(self.phone) {[weak self] (response) in
            self?.handleResponse(response: response, preReloadHandler: {
                let uid = try? response.get()
                self?.verificationID = uid ?? ""
                self?.rescheduleTimer()
            })
        }
    }
    
    var resendIsAvailable: Bool {
        return elapsed == 0
    }
    
    override func willDisappear() {
        super.willDisappear()
        self.timer?.invalidate()
        self.timer = nil
    }
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
}
