//
//  DashboardManager.swift
//  TheFloowApp
//
//  Created by Archana on 9/22/18.
//  Copyright © 2018 Archana Chaurasia. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class DashboardManager: NSObject {

  func checkIfLocationPermissionAvailable() -> (Bool, String) {

    if !CLLocationManager.locationServicesEnabled() {
      print("Please enable location services")
      return (false,"Please enable location services from privacy settings")

    } else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied {
      print("Please authorize location services")
      return (false,"Please enable location services for App")
    } else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways {
      return (true,"")
    }
    else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
      return (true,"")
    } else {
      return (false, "Please enable location services for App")
    }
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
        ) as! Location

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

//  func loadLastJourney() {
//
//    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//      return
//    }
//
//    let managedContext = appDelegate.persistentContainer.viewContext
//
//    var journeys  = [Journey]()
//
//    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Journey")
//    journeys = try! managedContext.fetch(fetchRequest) as! [Journey]
//
//    // Then you can use your properties.
//
//    guard let userJourney = journeys.last else {
//      print("current location not found")
//      return;
//    }
//
//    let userPath = GMSMutablePath()
//
//    let allPaths: [Location] = userJourney.path?.allObjects as! [Location]
//
//    for location in allPaths {
//      let coordinate = CLLocationCoordinate2D(latitude: location.lattitude, longitude: location.longitude)
//      userPath.add(coordinate)
//    }
//    let route = GMSPolyline(path: userPath)
//    route.map = mapView
//  }

}
