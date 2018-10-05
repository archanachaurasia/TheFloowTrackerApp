//
//  JourneyListManager.swift
//  TheFloowApp
//
//  Created by Archana on 9/22/18.
//  Copyright © 2018 Archana Chaurasia. All rights reserved.
//

import UIKit
import CoreData

class JourneyListManager: NSObject {

  func fetchAllJourneys() -> [Journey] {

    // This can be used to fetch journeys from, Coredata or webservice, or a combination of both.
    let appDelegate = UIApplication.shared.delegate as? AppDelegate

    let managedContext = appDelegate?.persistentContainer.viewContext

    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Journey")
    let arrJourney = try! managedContext?.fetch(fetchRequest) as! [Journey]
    return arrJourney
  }

}
