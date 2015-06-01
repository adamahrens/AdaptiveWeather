//
//  ViewController.swift
//  AdaptiveWeather
//
//  Created by Adam Ahrens on 5/26/15.
//  Copyright (c) 2015 Appsbyahrens. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    typealias Location = CLLocation
    
    //MARK: IBOutlets
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var localityLabel: UILabel!
    
    private var currentLocation: Location? {
        didSet {
            fetchLatestWeatherData()
        }
    }
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newLocation:", name: "NewLocationNotification", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: NSNotifications
    func newLocation(notification: NSNotification) {
        if let updatedLocation = notification.object as? Location {
            currentLocation = updatedLocation
        }
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
                        
                        // Reverse Geolocation for locality
                        let geolocation = CLGeocoder()
                        geolocation.reverseGeocodeLocation(location) { placemarks, error in
                            if placemarks.count > 0 {
                                if let placemark = placemarks.first as? CLPlacemark {
                                    // Update UI
                                    NSOperationQueue.mainQueue().addOperation(NSBlockOperation(block: { [weak self] in
                                        if let strongSelf = self {
                                            strongSelf.temperatureLabel.text = NSString(format:"%.1f ℉", fahrenheit) as String
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

