//
//  UserJourney.swift
//  TheFloowApp
//
//  Created by Bonnie Jaiswal on 9/16/18.
//  Copyright © 2018 Archana Chaurasia. All rights reserved.
//

import Foundation
import CoreLocation

struct UserJourney {

  var path = [CLLocationCoordinate2D]()
  var startDate = Date()
  var endDate: Date!
}
