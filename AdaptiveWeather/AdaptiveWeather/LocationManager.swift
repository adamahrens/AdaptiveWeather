//
//  LocationManager.swift
//  AdaptiveWeather
//
//  Created by Adam Ahrens on 5/31/15.
//  Copyright (c) 2015 Appsbyahrens. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    //MARK: Singleton
    static let sharedManager = LocationManager()
    
    //MARK: Private
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        // Get Location Updates
        locationManager.delegate = self
        
        let currentStatus = CLLocationManager.authorizationStatus()
        if currentStatus == .Restricted || currentStatus == .Denied || currentStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    //MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        newLocation
         NSNotificationCenter.defaultCenter().postNotificationName("NewLocationNotification", object: newLocation)
        locationManager.stopUpdatingLocation()
    }
}