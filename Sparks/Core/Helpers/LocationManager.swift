//
//  LocationManager.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 3/3/20.
//  Copyright © 2020 Sparks. All rights reserved.
//

import Foundation
import CoreLocation
import CoreGraphics
import UIKit

@objc protocol LocationManagerDelegate {
    func didUpdateTo(_ lat: Double, _ lng: Double)
    @objc optional func didChange(status: CLAuthorizationStatus)
    @objc optional func didUpdate(degree: CGFloat)
}

class LocationManager : NSObject {

    private let kDistanceFilter: CLLocationDistance = 300
    private let kLastCoordinates = "lastCoordinates"
    private let kPermissionRequested = "permissionRequested"
    
    weak var delegate  :LocationManagerDelegate?
    
    static let sharedInstance : LocationManager = {
        let instance = LocationManager()
        return instance
    }()

    private let locationManager  = CLLocationManager()
    
    private(set) var lastCoordinates: CLLocationCoordinate2D? {
        set {
            
            guard let lat = newValue?.latitude, let lng = newValue?.longitude else { return }
            UserDefaults.standard.set(["latitude": lat, "longitude": lng], forKey: kLastCoordinates)
            UserDefaults.standard.synchronize()
        }
        get {
            
            guard let coordinates = UserDefaults.standard.object(forKey: kLastCoordinates) as? [String: CLLocationDegrees],
                    let latitude = coordinates["latitude"], let longitude = coordinates["longitude"] else {
                return nil
            }
            
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    private(set) var permissionRequested: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: kPermissionRequested)
            UserDefaults.standard.synchronize()
        }
        get {
            UserDefaults.standard.bool(forKey: kPermissionRequested)
        }
    }

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.pausesLocationUpdatesAutomatically = true
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.activityType = .other
        self.locationManager.distanceFilter = kDistanceFilter
        self.locationManager.showsBackgroundLocationIndicator = false
        self.locationManager.allowsBackgroundLocationUpdates = false
        NotificationCenter.default.addObserver(forName: Consts.Notifications.didChangeLocationPermissions,
                                               object: nil, queue: nil) {[weak self] (_) in
            
            if self?.isLocationServiceEnabled() == true {
                self?.startUpdating()
            }
        }
    }

    func requestAuthorization() {
        
        if !permissionRequested {
            self.locationManager.requestWhenInUseAuthorization()
            permissionRequested = true
        } else if !self.isLocationServiceEnabled() {
            guard let url = URL(string:UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        }
    }

    func isLocationServiceEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled() && isAuthorizationOk()
    }
    
    func isAuthorizationOk() -> Bool {
        CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
    }
    
    func startUpdating() {
        self.locationManager.startUpdatingLocation()
    }

    func stopUpdating() {
        self.locationManager.stopUpdatingLocation()
    }
    
    func restart(for interval: TimeInterval = 5) {
        self.stopUpdating()
        background(block: {
            self.startUpdating()
        }, after: interval)
    }
    
    func enableBackgroundUpdates() {
        self.locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func disableBackgroundUpdates() {
        self.locationManager.allowsBackgroundLocationUpdates = false
    }
    
    func startMonitoringSignificantLocationChanges() {
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            // The device does not support this service.
            return
        }
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitoringSignificantLocationChanges() {
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            // The device does not support this service.
            return
        }
        locationManager.stopMonitoringSignificantLocationChanges()
    }
}

extension LocationManager : CLLocationManagerDelegate {

    private func distance(from coordinates: CLLocationCoordinate2D) -> Double? {
        if let lastCoords = self.lastCoordinates {
            let loc1 = CLLocation(latitude: lastCoords.latitude, longitude: lastCoords.longitude)
            let loc2 = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            return distanceDouble(between: loc1, location2: loc2, measureType: .MT)
        }
        
        return nil
    }
    
    private func userDistance(from coordinates: CLLocationCoordinate2D) -> Double? {
        if let user = User.current {
            let loc1 = CLLocation(latitude: user.lat, longitude: user.lng)
            let loc2 = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            return distanceDouble(between: loc1, location2: loc2, measureType: .MT)
        }
        
        return nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first?.coordinate else { return }
        guard location.latitude > 0, location.longitude > 0 else { return }
        let lat = locations[0].coordinate.latitude;
        let lng = locations[0].coordinate.longitude;
        
        if let value = self.distance(from: location) {
            if value >= kDistanceFilter {
                self.delegate?.didUpdateTo(lat, lng)
            } else if let userValue = userDistance(from: location) {
                if userValue >= kDistanceFilter {
                    self.delegate?.didUpdateTo(lat, lng)
                }
            }
        } else {
            self.delegate?.didUpdateTo(lat, lng)
        }
        
        print("CLLocationManager:didUpdateLocations: \(lat),\(lng)")
        
        self.lastCoordinates = location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("CLLocationManager:didFailWithError: \(error)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.delegate?.didChange?(status: status)
        NotificationCenter.default.post(name: Consts.Notifications.didChangeLocationPermissions, object: status)
        
        if status == .authorizedWhenInUse {
            self.locationManager.requestAlwaysAuthorization()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.delegate?.didUpdate?(degree: CGFloat(newHeading.trueHeading))
    }
}
