//
//  ViewController.swift
//  AdaptiveWeather
//
//  Created by Adam Ahrens on 5/26/15.
//  Copyright (c) 2015 Appsbyahrens. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    typealias Location = CLLocation
    
    //MARK: IBOutlets
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var localityLabel: UILabel!
    
    //MARK: Private Variables
    private let locationManager = CLLocationManager()
    private var currentLocation: Location? {
        didSet {
            fetchLatestWeatherData()
        }
    }
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get Location Updates
        locationManager.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        // Ask for permission if necessary
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
        currentLocation = newLocation
        locationManager.stopUpdatingLocation()
    }
    
    //MARK: Helpers
    private func fetchLatestWeatherData() {
        if let location = currentLocation {
            let url = NSURL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)")
            let request = NSURLRequest(URL: url!)
            let urlSession = NSURLSession.sharedSession()
            
            // Fetch the weather
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            urlSession.dataTaskWithRequest(request) { [weak self] data, response, error in
                if let strongSelf = self {
                    let json = JSON(data: data)
                    let kelvin = json["main"]["temp"].stringValue
                    if let k = NSNumberFormatter().numberFromString(kelvin)?.doubleValue {
                        // Convert to Fahrenheit
                        let fahrenheit = ((k - 273.15) * 1.8) + 32.0

                        // Update UI
                        NSOperationQueue.mainQueue().addOperation(NSBlockOperation(block: { [weak self] in
                            if let strongSelf = self {
                                strongSelf.temperatureLabel.text = NSString(format:"%.1f ℉", fahrenheit) as String
                            }
                        }))
                        
                        // Reverse Geolocation for locality
                        let geolocation = CLGeocoder()
                        geolocation.reverseGeocodeLocation(location) { placemarks, error in
                            if placemarks.count > 0 {
                                if let placemark = placemarks.first as? CLPlacemark {
                                    // Update UI
                                    NSOperationQueue.mainQueue().addOperation(NSBlockOperation(block: { [weak self] in
                                        if let strongSelf = self {
                                            strongSelf.localityLabel.text = placemark.locality
                                            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                                        }
                                    }))
                                }
                            }
                        }
                    }
                }
            }.resume()
        }
    }
}

