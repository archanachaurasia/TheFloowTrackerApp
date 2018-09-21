//
//  JourneyListViewController.swift
//  TheFloowApp
//
//  Created by Archana on 9/16/18.
//  Copyright © 2018 Archana Chaurasia. All rights reserved.
//

import UIKit
import CoreData

class JourneyListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!

  var arrJourneys: [Journey]?

  override func viewDidLoad() {
      super.viewDidLoad()

      // Do any additional setup after loading the view.
    loadAllJourneys()
  }

  func loadAllJourneys() {

    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }

    let managedContext = appDelegate.persistentContainer.viewContext

    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Journey")
    arrJourneys = try! managedContext.fetch(fetchRequest) as! [Journey]
    tableView.reloadData()
  }

  // MARK: -  TableView Datasource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    guard (arrJourneys?.count)! > 0, let count = arrJourneys?.count else {
      return 0;
    }
    return count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "JourneyListCell")!
    cell.textLabel?.numberOfLines=0
    cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping

    let journey = arrJourneys?[indexPath.row]
    
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = "yyyy-MM-dd"
    let startDate: String? = dateFormatterGet.string(from: (journey?.startDate)!)
    let endDate: String? = dateFormatterGet.string(from: (journey?.endDate)!)
    
    dateFormatterGet.dateFormat = "HH:mm:ss"
    let startTime: String? = dateFormatterGet.string(from: (journey?.startDate)!)
    let endTime: String? = dateFormatterGet.string(from: (journey?.endDate)!)

    
    cell.textLabel?.text = "Journey started on \(String(describing: startDate!)) at \(String(describing: startTime!)) Journey ended on \(String(describing: endDate!)) at \(String(describing: endTime!))"
    return cell
  }

  // MARK: -  TableView Delegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
