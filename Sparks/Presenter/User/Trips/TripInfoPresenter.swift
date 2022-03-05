//
//  TripInfoPresenter.swift
//  Sparks
//
//  Created by Adroit Jimmy on 13/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import RealmSwift

protocol TripInfoView: BasePresenterView {
    func setTitle(title: String)
    func loadImage(url: URL?)
    func updateConnectButtonState(enabled: Bool, isConnected: Bool, text: String)
    func navigate()
}

class TripInfoPresenter: BasePresenter<TripInfoView>, PreviewConfiguration {
    
    private(set) var channelService: ChatService!
    private var token: NotificationToken?
    private(set) var trip: Trip!
    var data: [PreviewModel]?{
        return self.preparePreview()
    }

    convenience init(trip: Trip){
        self.init()
        channelService = Service.chat
        self.trip = trip
    }
    
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        self.view?.setTitle(title: self.trip.user?.firstName ?? "")
        self.view?.updateConnectButtonState(enabled: false, isConnected: false, text: "Loading ...")
        let url = URL(string: self.trip.user?.photoUrl ?? "")
        self.view?.loadImage(url: url)
        self.observeChannels()
    }
    
    func observeChannels() {
        token = RealmUtils.observeChannels(forUser: self.trip.user?.uid ?? "", completion: { channels, _, _, _ in
            main {
                if let first = channels.first {
                    switch first.statusEnum {
                    case .accepted:
                        self.view?.updateConnectButtonState(enabled: true, isConnected: true, text: "Unfollow")
                        break;
                    case .requested:
                        if first.createdBy == User.current?.uid {
                            self.view?.updateConnectButtonState(enabled: false, isConnected: false, text: "Sent")
                        } else {
                            self.view?.updateConnectButtonState(enabled: true, isConnected: false, text: "Accept")
                        }
                        
                        break;
                    default:
                        self.view?.updateConnectButtonState(enabled: true, isConnected: false, text: "Follow")
                        break
                    }
                } else {
                    self.view?.updateConnectButtonState(enabled: true, isConnected: false, text: "Follow")
                }
            }
        })
    }
    
    func preparePreview() -> [PreviewModel] {
        
        let stDate = self.trip.startDate.toDate.toString("dd MMM, yyyy", localeIdentifier: Locale.current.identifier)
        let endDate = self.trip.endDate.toDate.toString("dd MMM, yyyy", localeIdentifier: Locale.current.identifier)
        
        let purpose = PurposeEnum(rawValue: self.trip.purpose) ?? .leisure
        let community = TripCommunityEnum(rawValue: self.trip.community) ?? .alone

        return [
            PreviewModel(icon: "icn-loc", text: self.trip.city),
            PreviewModel(icon: "icn-cal", text: "\(stDate) - \(endDate)"),
            PreviewModel(icon: "icn-purpose", text: purpose.getLabel()),
            PreviewModel(icon: "icn-grp", text: community.getLabel()),
            PreviewModel(icon: "icn-info", text: self.trip.plan)
        ]
    }
    
    func configure(cell: PreviewCell, indexPath: IndexPath){
        guard let model = self.data?[indexPath.row] else {return}
        cell.configure(icn: model.icon, text: model.text)
    }
    
    func askToConnect() {
        guard let uid = trip.userId else {
            self.view?.reloadView()
            return
        }
        
        self.view?.updateConnectButtonState(enabled: false, isConnected: false, text: "Sent")
        channelService.connectToUser(uid) {[weak self] response in
            self?.handleResponse(response: response, errorHandler: { error in
                self?.view?.reloadView()
            }, reload: true)
        }
    }
    
    func viewProfile() {
        guard let uid = trip.userId else {
            self.view?.reloadView()
            return
        }
        let presenter = ProfilePresenter()
        self.view?.navigate()
    }

    deinit {
        token?.invalidate()
    }
}
