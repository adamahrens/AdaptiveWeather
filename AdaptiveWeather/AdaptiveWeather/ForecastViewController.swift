//
//  ForecastViewController.swift
//  AdaptiveWeather
//
//  Created by Adam Ahrens on 5/31/15.
//  Copyright (c) 2015 Appsbyahrens. All rights reserved.
//

import UIKit
import CoreLocation

class ForecastViewController: UIViewController, UICollectionViewDataSource {

    typealias Location = CLLocation
    
    private var currentLocation: Location? {
        didSet {
            fetchLatestForecastData()
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
    
    //MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DailyWeatherCollectionViewCell", forIndexPath: indexPath) as! DailyWeatherCollectionViewCell
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    //MARK: Private
    func fetchLatestForecastData() {
        //http://api.openweathermap.org/data/2.5/forecast/daily?lat=35&lon=139&cnt=10&mode=json
        if let location = currentLocation {
            let url = NSURL(string: "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&cnt=10&mode=json")
            let request = NSURLRequest(URL: url!)
            let urlSession = NSURLSession.sharedSession()
            
            // Fetch the weather
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            urlSession.dataTaskWithRequest(request) { [weak self] data, response, error in
                if let strongSelf = self {
                    let json = JSON(data: data)
                }
            }.resume()
        }

    }
}
