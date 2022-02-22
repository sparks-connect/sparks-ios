//
//  PlacesPresenter.swift
//  Sparks
//
//  Created by Adroit Jimmy on 09/02/22.
//  Copyright © 2022 AppWork. All rights reserved.
//

import Foundation
import GooglePlaces

protocol PlaceView: BasePresenterView {
    func dismiss()
}

struct PlaceInfo {
    var place: String?
    var coordinates: CLLocationCoordinate2D?
}

protocol Place: AnyObject {
    func getLocation(info: PlaceInfo)
}

class PlacesPresenter: BasePresenter<PlaceView>, GMSAutocompleteFetcherDelegate {

    private var fetcher: GMSAutocompleteFetcher?
    lazy var predictions = [GMSAutocompletePrediction]()
    var placeInfo: PlaceInfo?
    override func onFirstViewAttach() {
        super.onFirstViewAttach()
        configurePlaces()
    }

    func configurePlaces(){
        // Set up the autocomplete filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        
        // Create a new session token.
        let token: GMSAutocompleteSessionToken = GMSAutocompleteSessionToken.init()
        
        // Create the fetcher.
        fetcher = GMSAutocompleteFetcher(filter: filter)
        fetcher?.delegate = self
        
        fetcher?.provide(token)
    }
    
    func textChanged(text: String?){
        if !text.isEmpty {
            self.fetcher?.sourceTextHasChanged(text)
        }
    }
    
    func configureCell(cell: UITableViewCell, indexPath: IndexPath){
        cell.textLabel?.text = self.predictions[indexPath.row].attributedFullText.string
    }
    
    func getLocation(indexPath: IndexPath){
        let prediction = self.predictions[indexPath.row]
        let city = prediction.attributedFullText.string
        let placesClient = GMSPlacesClient.shared()
        placesClient.lookUpPlaceID(prediction.placeID) { (place, error) in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details for \(prediction.placeID)")
                return
            }
            main {
                self.placeInfo = PlaceInfo(place: city, coordinates: place.coordinate)
                self.view?.dismiss()
            }
        }
    }
    
    func sendLocation(place: Place?){
        if let info = placeInfo {
            place?.getLocation(info: info)
        }
    }
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        self.predictions = predictions
        self.view?.reloadView()
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        self.view?.notifyError(message: error.localizedDescription, okAction: nil)
    }
}
