//
//  ViewController.swift
//  WhereTo
//
//  Created by Prateek Kansara on 04/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet private var mapView : MKMapView!
    @IBOutlet private var venueDataView: UIView!
    @IBOutlet private var centrePin : UIImageView!
    @IBOutlet private var radiusSlider : UISlider!
    @IBOutlet private var sliderWidthConstraint : NSLayoutConstraint!
    @IBOutlet private var zoomButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

//        mapView.delegate = self
        mapView.showsUserLocation = true
        
        let buttonItem = MKUserTrackingBarButtonItem(mapView: mapView)
        self.navigationItem.rightBarButtonItem = buttonItem
        
        setupNetworkUpdate()
        setupLocationManager()
        addCentrePin()
        
        self.sliderWidthConstraint.constant = 0
        
        mapView.register(WTCustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        zoomButton.set(corner: 5.0)
    }
    
    
    /// Location Authorization Method
    func setupLocationManager(){
        
        var curLocation = mapView.centerCoordinate
        if WTLocationManager.shared.isLocationEnabled, let currentLocation = WTLocationManager.shared.currentUserLocation{
            curLocation = currentLocation
        }else{
            WTLocationManager.shared.requestLocationAuthorization()
        }
        
        updateMapView(location: curLocation)
        
        WTLocationManager.shared.locationUpdateHandler = {
            location in
            if location != nil{
                let locObj = self.locationObj(location: location!)
                self.updateMapView(location: CLLocationCoordinate2D(latitude: locObj.lat, longitude: locObj.lng))
            }else{
                self.clearMap()
            }
        }
    }
    
    
    /// Method to update map view to given coordinates
    ///
    /// - Parameter location: Coordinagte to render map to
    private func updateMapView(location : CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: location, latitudinalMeters: CLLocationDistance(exactly: self.radiusSlider.value+5000)!, longitudinalMeters: CLLocationDistance(exactly: self.radiusSlider.value+5000)!)
        mapView.setRegion(mapView.regionThatFits(region), animated: false)
        
        let locObj = locationObj(location: location)
        WTAPIService.shared.fetchVenues(location: locObj, radius: Double(self.radiusSlider!.value))
    }
    
    
    /// Method to update Centre pin on Map
    private var circle : MKCircle?
    private func addCentrePin(){
        let newPoint = self.mapView.convert(mapView.centerCoordinate, toPointTo: self.view)

        self.centrePin.center = newPoint
        self.updateRadiusCircle()
    }
    
    
    /// Method to update radius circle
    private func updateRadiusCircle(){
        if circle != nil{
            mapView.removeOverlay(circle!)
        }
        
        circle = MKCircle(center: mapView.centerCoordinate, radius: CLLocationDistance(self.radiusSlider!.value))
        mapView.addOverlay(circle!)
    }
    
    
    /// Method to update UI if any new data is been downloaded
    private func setupNetworkUpdate(){
        WTAPIService.shared.reloadUI = {
            isSuccess in
            if isSuccess{
                // reload UI
                self.reloadVenueCollection()
                
            }else{
                self.clearMap()
            }
        }
    }
    
    /// Update venue data list
    func reloadVenueCollection(){
        self.venuesCollectionView.reloadData()
    }
    
    
    /// Method to convert CLLocationCoordinate2D Object to Location object
    ///
    /// - Parameter location: CLLocationCoordinate2D object
    /// - Returns: Location Model Object
    private func locationObj(location : CLLocationCoordinate2D) -> Location{
        var locationObj = Location()
        locationObj.lat = location.latitude
        locationObj.lng = location.longitude
        return locationObj
    }
    
    /// Method to clear map
    private func clearMap(){
        if mapView.annotations.count > 0{
            mapView.removeAnnotations(mapView.annotations)
        }
    }
    
    @IBAction func userLocationTapped(sender : UIButton){
        updateMapView(location: mapView.userLocation.coordinate)
        addCentrePin()
    }
    
    @IBAction func radiusButtonPressed(sender : UIButton){
        sliderToggle()
    }
    
    private let sliderWidth : CGFloat = 163
    private func sliderToggle(){
        if self.sliderWidthConstraint.constant == 0{
            self.radiusSlider.isHidden = false
            
            UIView.animate(withDuration: 0.5, animations: {
                self.sliderWidthConstraint.constant = self.sliderWidth
            }, completion: {
                completed in
            })
        }else{
            UIView.animate(withDuration: 0.5, animations: {
                self.sliderWidthConstraint.constant = 0
            }, completion: {
                completed in
                self.radiusSlider.isHidden = true
            })
        }
        
    }

    @IBAction func sliderValueChanged(_ sender: UISlider, forEvent event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began, .moved:
                self.updateRadiusCircle()
                break
            case .ended:
                updateMapView(location: mapView.centerCoordinate)
                break
            default:
                break
            }
        }
    }
    
    fileprivate var isZoomEnabled = false
    @IBAction func enableZoom(sender : UIButton){
        isZoomEnabled = !isZoomEnabled
        isZoomEnabled ? (sender.backgroundColor = .darkGray) : (sender.backgroundColor = .clear)
    }
    
    private var venuesCollectionView : WTVenueCollectionViewController!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "venues"{
            self.venuesCollectionView = segue.destination as? WTVenueCollectionViewController
            self.venuesCollectionView.updateMapToIndex = {
                indexPath in
                if indexPath == nil{
                    self.addMarkersToMap()
                }else{
                    self.moveToMarker(indexPath: indexPath!)
                }
            }
        }
    }
    
    fileprivate var isMarkerSelectedFromCell = false
    
    /// Method to select a specific marker on the map
    ///
    /// - Parameter indexPath: Indexpath of the marker
    private func moveToMarker(indexPath : IndexPath){
        if self.mapView.annotations.count > indexPath.row{
            isMarkerSelectedFromCell = true
            
            let annotation = self.mapView.annotations.filter { (annotation) -> Bool in
                    if let customAnnotation = annotation as? WTCustomPointAnnotation{
                        return customAnnotation.indexPath == indexPath
                    }
                    return false
                }
            
            
            if let selectedAnnotation = annotation.first{
                self.mapView.selectAnnotation(selectedAnnotation, animated: true)
            }
        }
    }

    
    /// Method to add marker on the map
    private func addMarkersToMap(){
        clearMap()
        let markers = self.venuesCollectionView.venueLocations
        var mapAnnotations = [WTCustomPointAnnotation]()
        for marker in markers!{
            let annotation = WTCustomPointAnnotation()
            annotation.title = marker["name"] as? String
            let annotationLocation = CLLocationCoordinate2D(latitude: marker["lat"] as! Double, longitude: marker["lng"] as! Double)
            annotation.coordinate = annotationLocation
            annotation.indexPath = IndexPath(row: marker["row"] as! Int, section: marker["section"] as! Int)
            mapAnnotations.append(annotation)
        }
        
        self.mapView.addAnnotations(mapAnnotations)
        
    }
}

extension ViewController : MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        WTLocationManager.shared.currentUserLocation = userLocation.coordinate
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if !isMarkerSelectedFromCell, let annotation = view.annotation as? WTCustomPointAnnotation{
            self.venuesCollectionView.showVenueCellAt(indexPath: annotation.indexPath)
        }
        isMarkerSelectedFromCell = false
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if !isZoomEnabled{
            addCentrePin()
            updateMapView(location: mapView.centerCoordinate)
        }
    }
   
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        if view == nil{
            view = MKMarkerAnnotationView(annotation: nil, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        }
        view?.annotation = annotation
        view?.displayPriority = .required
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.red
            circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
            circle.lineWidth = 1
            return circle
        } else {
            
        }
        return MKOverlayRenderer()
    }
}
