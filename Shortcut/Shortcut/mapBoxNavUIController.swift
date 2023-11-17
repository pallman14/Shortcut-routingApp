//  Price Allman
//  mapBoxNavUIController.swift
//  Shortcut


import UIKit
import SwiftUI
import MapKit
import MapboxNavigation
import MapboxMaps
import MapboxDirections
import MapboxCoreNavigation
import MapboxCommon
import MapboxCoreMaps
import UserNotifications

class mapBoxNavUIController: UIViewController, MKMapViewDelegate, ErrorDelegate {
 // Catch the error from RouteCalculator and show it
    func catchError(_ error: Error) {
        // Display an alert with the error message
        let alert = UIAlertController(title: "Error", message: "An error has occured: \(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {[unowned self] action in
            // Dismiss the alert and navigate back to the previous view controller
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true)
    }

    // Arrays to store MapKit map items and Mapbox waypoints
    var mapItems = [MKMapItem]()
    var mapBoxWaypoints = [Waypoint]()
    
    // MapView for displaying the mapBox navigation
    var mapView: NavigationMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize and configure the MapView
        mapView = NavigationMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapView)
        
        // Iterate through the MapKit map items to create Mapbox waypoints
        for index in 0..<mapItems.count {
            let mapItem = mapItems[index]
            let MBlatitude = mapItem.placemark.coordinate.latitude
            let MBlongitude = mapItem.placemark.coordinate.longitude
            
            // Provide a default name if the mapItem doesn't have a name
            let name = mapItem.name ?? "Waypoint"
            
            // Create a Mapbox waypoint and add it to the array
            let waypoint = Waypoint(coordinate: LocationCoordinate2D(latitude: MBlatitude, longitude: MBlongitude), name: name)
            
            mapBoxWaypoints.append(waypoint)
        }
        
        // Add the starting location as the last waypoint
        if let startingLocation = mapBoxWaypoints.first {
            mapBoxWaypoints.append(startingLocation)
        }
            
        // Create route options using the Mapbox waypoints
        let routeOptions = NavigationRouteOptions(waypoints: mapBoxWaypoints)
        
        // Use Mapbox Directions API to calculate the route
        Directions.shared.calculate(routeOptions) {session, result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                // Showcase the routes on the MapView
                self.mapView.showcase(response.routes ?? [])
                
                // Initialize and present the NavigationViewController with the calculated route
                let navigationViewController = NavigationViewController(for: response, routeIndex: 0, routeOptions: routeOptions)
                self.present(navigationViewController, animated: true)
            }
        }
    }
    
   /* func checkForPermission() {
        let notificationCenter = UNUserNotificationCenter.current()
    }*/
}

 // A convenient extension to create a predefined user location coordinate.
 extension CLLocationCoordinate2D {
     static var userLocation: CLLocationCoordinate2D {
         //ORU
     return .init(latitude: 25.7602, longitude: -80.1959)
     }
 }
 // A convenient extension to create a predefined region centered on the user location with a specified span.
 extension MKCoordinateRegion {
     static var userRegion: MKCoordinateRegion {
     return .init(center: .userLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
     }
 }
     

