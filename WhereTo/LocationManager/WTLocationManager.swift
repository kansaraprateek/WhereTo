//
//  WTLocationManager.swift
//  WhereTo
//
//  Created by Prateek Kansara on 05/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import Foundation
import CoreLocation

/// Location Manager Class

/*
 To Authenticate user location and determine any changes to user location
 */
class WTLocationManager : NSObject{
    
    static let shared = WTLocationManager()
    
    private var locationManager : CLLocationManager!
    
    var currentLocation : CLLocationCoordinate2D?{
        didSet{
//            self.updateMapView(location: self.currentLocation)
        }
    }
    var currentUserLocation : CLLocationCoordinate2D?{
        didSet{
            if isCurrentLocationEmpty{
                isCurrentLocationEmpty = false
                self.updateMapView(location: self.currentUserLocation)
            }
        }
    }
    
    var isLocationEnabled : Bool{
        return CLLocationManager.locationServicesEnabled()
    }
    
    private func updateMapView(location : CLLocationCoordinate2D?){
        if self.locationUpdateHandler != nil{
            self.locationUpdateHandler!(location)
        }
    }
    
    override private init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func requestLocationAuthorization(){
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Handler to update UI if location is changed
    var locationUpdateHandler : ((CLLocationCoordinate2D?) -> Void)?
    
    fileprivate var isCurrentLocationEmpty = false
}

extension WTLocationManager : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status != .denied || status != .restricted{
            locationManager.startUpdatingLocation()
        }else{
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let last = locations.last{
            if self.currentLocation == nil {isCurrentLocationEmpty = true}
            self.currentLocation = last.coordinate
        }
    }
}
