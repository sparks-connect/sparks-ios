//
//  NewMessageController.swift
//  Sparks
//
//  Created by Nika Samadashvili on 5/26/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation

protocol NewMessageView: BasePresenterView {
  func didSentMessage()
}

class NewMessagePresenter : BasePresenter<NewMessageView>{
    
    private var service: ChatService!
    
    init(service: ChatService = Service.chat) {
         super.init()
         self.service = service
    }
     
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        self.auth.restartGPSTracking(interval: 10)
    }
    
    func sendRequestwith(text: String){
        service.sendSpark(withLetter: text) {[weak self] (resp) in
            self?.handleResponse(response: resp, preReloadHandler: {
                self?.view?.didSentMessage()
            })
        }
    }
}
