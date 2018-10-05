//
//  UserJourney.swift
//  TheFloowApp
//
//  Created by Archana on 9/16/18.
//  Copyright © 2018 Archana Chaurasia. All rights reserved.
//

import Foundation
import CoreLocation

protocol UserJourneyDelegate {
  func userDidMove(toLocation coordinate: CLLocationCoordinate2D)
}

struct UserJourney {

  var delegate: UserJourneyDelegate

  init(withDelegate object: UserJourneyDelegate) {
    delegate = object
  }

  var path = [CLLocationCoordinate2D]() {
    didSet {
      delegate.userDidMove(toLocation: path.last!)
    }
  }
  var startDate = Date()
  var endDate: Date!
}
