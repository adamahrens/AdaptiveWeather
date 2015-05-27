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
            urlSession.dataTaskWithRequest(request) { data, response, error in
                let json = JSON(data: data)
                let kelvin = json["main"]["temp"].stringValue
                if let k = NSNumberFormatter().numberFromString(kelvin)?.doubleValue {
                    // Convert to Fahrenheit
                    let fahrenheit = ((k - 273.15) * 1.8) + 32.0
                    self.temperatureLabel.text = "\(fahrenheit) ℉"
                }
            }.resume()
        }
    }
}

