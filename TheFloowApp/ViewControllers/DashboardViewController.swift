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

class DashboardViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

  struct Constants {
    static let JourneyListSegue = "showJourneyListVC"
    static let mapCameraZoom :Float = 17.0; //google map level
    static let googleMapApiKey = "AIzaSyDSL3C3kbaXKheOcnojgsDXAYNtJrYxDkQ" //generate key on google map via login
  }

  var locationManager: CLLocationManager!
  var lastKnownLocation: CLLocation?
  var mapView: GMSMapView!
  let path = GMSMutablePath()
  var currentJourney: UserJourney?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    self.title = NSLocalizedString("The Floow App", comment: "main view title (app name)")

    currentJourney = UserJourney() //initialization

    GMSServices.provideAPIKey(Constants.googleMapApiKey) // map settings/configuration

    let camera = GMSCameraPosition.camera(
      withLatitude: 38.8879, //default location on launch
      longitude: -77.0200,
      zoom: Constants.mapCameraZoom
    )

    mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
    mapView.settings.myLocationButton = true //map settingsß
    mapView.settings.indoorPicker = false
    mapView.isMyLocationEnabled = true
    mapView.delegate = self
    self.view = mapView;

    if !CLLocationManager.locationServicesEnabled() {
      print("Please enable location services")
      self.view.makeToast(NSLocalizedString("Please enable location services from privacy settings", comment: ""))
      return
    }

    if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied {
      print("Please authorize location services")
      self.view.makeToast(NSLocalizedString("Please enable location services for App", comment: ""))
      return
    }

    locationManager = CLLocationManager()
    if (locationManager.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization))) {
      locationManager.requestAlwaysAuthorization()
    }
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()

  }

  @IBAction func switchValueDidChange(_ sender: UISwitch) {
    if sender.isOn {
      print("Location Tracking ON")
      currentJourney = UserJourney()
      locationManager.startUpdatingLocation()
    } else{
      print("Location Tracking OFF")
      saveUserJourney(lastJourney: currentJourney!)
      currentJourney = nil
      lastKnownLocation = nil
      locationManager.stopUpdatingLocation()
    }
  }

  @IBAction func showListBtnPressed(_ sender: UIButton) {

    performSegue(withIdentifier: Constants.JourneyListSegue, sender: self)
  }

  func loadLastJourney() {

    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }

    let managedContext = appDelegate.persistentContainer.viewContext

    var journeys  = [Journey]()

    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Journey")
    journeys = try! managedContext.fetch(fetchRequest) as! [Journey]

    // Then you can use your properties.

    guard let userJourney = journeys.last else {
      print("current location not found")
      return;
    }

    let userPath = GMSMutablePath()

    let allPaths: [Location] = userJourney.path?.allObjects as! [Location]

    for location in allPaths {
      let coordinate = CLLocationCoordinate2D(latitude: location.lattitude, longitude: location.longitude)
      userPath.add(coordinate)
    }
    let route = GMSPolyline(path: userPath)
    route.map = mapView
  }

  // MARK: - CLLocation Delgates

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

    if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied {
      print("Please authorize location services")
      self.view.makeToast(NSLocalizedString("Please enable location services", comment: ""))
      return
    }

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

      lastKnownLocation = currentLocation
        currentJourney?.path.append(currentLocation.coordinate)
    }
    else {
      guard let lastLocation = lastKnownLocation else {
        print("Last location not found")
        return;
      }
      // Forming GMSPath from User's last location to User's current location.
      let path = GMSMutablePath()
      path.add(lastLocation.coordinate)
      path.add(currentLocation.coordinate)

      let polyLine = GMSPolyline(path: path)
      polyLine.strokeWidth = 5.0;
      polyLine.map = mapView
      // Saving current loc as last known loc,so that we can draw another GMSPolyline from last location to current location when you recieved another callback for this method.
      lastKnownLocation = currentLocation;
      currentJourney?.path.append(currentLocation.coordinate)
    }

    // Draw as a single polyline.
    //    guard let currentLocation = locations.last else {
    //      print("current location not found")
    //      return;
    //    }
    //
    //    path.add(currentLocation.coordinate)
    //
    //    let route = GMSPolyline(path: path)
    //    route.map = mapView

  }

  func saveUserJourney(lastJourney: UserJourney) {

    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }

    let managedContext = appDelegate.persistentContainer.viewContext

    let entity = NSEntityDescription.entity(
      forEntityName: "Journey",
      in: managedContext)!

    let journeyToSave = NSManagedObject(
      entity: entity,
      insertInto: managedContext
      ) as! Journey

    let pathEntity = NSEntityDescription.entity(
      forEntityName: "Location",
      in: managedContext)!

    for location in lastJourney.path {

      let path = NSManagedObject(
        entity: pathEntity,
        insertInto: managedContext
        ) as! Location //type cast

      path.lattitude = location.latitude
      path.longitude = location.longitude
      journeyToSave.addToPath(path)
    }

    journeyToSave.startDate = lastJourney.startDate
    journeyToSave.endDate = Date()

    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }
}
