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
    
    //MARK: NSLayoutConstraints
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    //MARK: Private Vars
    private var currentLocation: Location? {
        didSet {
            fetchLatestWeatherData()
        }
    }
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newLocation:", name: "NewLocationNotification", object: nil)
        
        configureTraitOverrideForSize(view.bounds.size, withTransitionCoordinator: nil)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        configureTraitOverrideForSize(size, withTransitionCoordinator: coordinator)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Used to prevent CollectionView from showing on iPhone
    private func configureTraitOverrideForSize(size: CGSize, withTransitionCoordinator: UIViewControllerTransitionCoordinator?) {
        var traitOverride: UITraitCollection?
        var newContainerHeight = CGFloat(0.0)
        if size.height < 1000 {
            traitOverride = UITraitCollection(verticalSizeClass: .Compact)
            // Need to adjust the layout constraint to shrink
            newContainerHeight = 0
        } else {
            // Need to adjust the layout constraint to grow
            newContainerHeight = 100
        }
        
        if let coordinator = withTransitionCoordinator {
            // Then lets animate
            coordinator.animateAlongsideTransition({ (coordinatorContext: UIViewControllerTransitionCoordinatorContext!) in
                self.containerViewHeight.constant = newContainerHeight
                self.view.setNeedsDisplay()
                }, completion: nil)
        } else {
            // Just set the constraint
            containerViewHeight.constant = newContainerHeight
            view.setNeedsDisplay()
        }
        
        for vc in childViewControllers as! [UIViewController] {
            setOverrideTraitCollection(traitOverride, forChildViewController: vc)
        }
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
                                        self?.temperatureLabel.text = NSString(format:"%.1f ℉", fahrenheit) as String
                                        self?.localityLabel.text = placemark.locality
                                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
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

