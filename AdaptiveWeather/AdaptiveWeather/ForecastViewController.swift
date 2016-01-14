//
//  ForecastViewController.swift
//  AdaptiveWeather
//
//  Created by Adam Ahrens on 5/31/15.
//  Copyright (c) 2015 Appsbyahrens. All rights reserved.
//

import UIKit
import CoreLocation

class ForecastViewController: UIViewController {

    typealias Location = CLLocation
    
    //MARK: IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: Private Properties
    private var currentLocation: Location? {
        didSet {
            fetchLatestForecastData()
        }
    }
    
    //MARK: Model
    var dataSource = [Forecast]()
    
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

    //MARK: Private
    private func fetchLatestForecastData() {
        if let location = currentLocation {
            let url = NSURL(string: "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&cnt=10&mode=json")
            let request = NSURLRequest(URL: url!)
            let urlSession = NSURLSession.sharedSession()
            
            // Fetch the forecast
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            urlSession.dataTaskWithRequest(request) { [weak self] data, response, error in
                guard let data = data else {
                    return
                }
                
                let json = JSON(data: data)
                self?.dataSource.removeAll(keepCapacity: true)
                for (_, subJSON) in json["list"] {
                    let forecast = Forecast(json: subJSON)
                    self?.dataSource.append(forecast)
                }
                
                //Reload Data
                self?.collectionView.reloadData()
            }.resume()
        }
    }
}

//MARK: UICollectionViewDataSource Extension
extension ForecastViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DailyWeatherCollectionViewCell", forIndexPath: indexPath) as! DailyWeatherCollectionViewCell
        cell.configureCellWithForecast(dataSource[indexPath.row])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
}
