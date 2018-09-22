//
//  ViewController.swift
//  TheFloowApp
//
//  Created by Archana on 9/16/18.
//  Copyright © 2018 Archana Chaurasia. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import Toast_Swift
import CoreData

class DashboardViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UserJourneyDelegate {

  struct Constants {
    static let JourneyListSegue = "showJourneyListVC"
    static let mapCameraZoom :Float = 17.0;
    static let googleMapApiKey = "AIzaSyDSL3C3kbaXKheOcnojgsDXAYNtJrYxDkQ"
  }

  var locationManager: CLLocationManager!
  var lastKnownLocation: CLLocationCoordinate2D?
  var mapView: GMSMapView!
  var currentJourney: UserJourney?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    self.title = NSLocalizedString("The Floow App", comment: "main view title (app name)")

    currentJourney = UserJourney(withDelegate: self)
    
    GMSServices.provideAPIKey(Constants.googleMapApiKey)

    let camera = GMSCameraPosition.camera(
      withLatitude: 38.8879,
      longitude: -77.0200,
      zoom: Constants.mapCameraZoom
    )

    mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
    mapView.settings.myLocationButton = true
    mapView.settings.indoorPicker = false
    mapView.isMyLocationEnabled = true
    mapView.delegate = self
    self.view = mapView;

    let manager = DashboardManager()

    let (permission, message) = manager.checkIfLocationPermissionAvailable()

    locationManager = CLLocationManager()

    if permission {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.startUpdatingLocation()
    } else {
      if (locationManager.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization))) {
        locationManager.requestAlwaysAuthorization()
      }
      self.view.makeToast(message)
    }
  }

  @IBAction func switchValueDidChange(_ sender: UISwitch) {
    if sender.isOn {
      print("Location Tracking ON")
      currentJourney = UserJourney(withDelegate: self)
      locationManager.startUpdatingLocation()
    } else{
      print("Location Tracking OFF")
      DashboardManager().saveUserJourney(lastJourney: currentJourney!)
      currentJourney = nil
      lastKnownLocation = nil
      locationManager.stopUpdatingLocation()
    }
  }

  @IBAction func showListBtnPressed(_ sender: UIButton) {
    performSegue(withIdentifier: Constants.JourneyListSegue, sender: self)
  }

  // MARK: - CLLocation Delgates

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    self.view.makeToast(NSLocalizedString("Could not determine location at the moment", comment: ""))
    print("CLLocationManager error: \(error.localizedDescription)")
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    guard let currentLocation = locations.last else {
      print("current location not found")
      return;
    }

    if(lastKnownLocation == nil) {

      let move = GMSCameraUpdate.setTarget(currentLocation.coordinate, zoom: Constants.mapCameraZoom)
      mapView.animate(with: move)

      lastKnownLocation = currentLocation.coordinate
    }

    currentJourney?.path.append(currentLocation.coordinate)
  }

  // MARK: - UserJourney Delgate

  func userDidMove(toLocation currentLocation: CLLocationCoordinate2D) {

    guard let lastLocation = lastKnownLocation else { return }
    // Forming GMSPath from User's last location to User's current location.
    let path = GMSMutablePath()
    path.add(lastLocation)
    path.add(currentLocation)

    let polyLine = GMSPolyline(path: path)
    polyLine.strokeWidth = 5.0;
    polyLine.map = mapView
    // Saving current loc as last known loc,so that we can draw another GMSPolyline from last location to current location when you recieved another callback for this method.
    lastKnownLocation = currentLocation;
  }
}
