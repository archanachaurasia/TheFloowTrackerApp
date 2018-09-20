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

    let journey = arrJourneys?[indexPath.row]
    cell.textLabel?.text = "Journey started on \(String(describing: journey?.startDate))!"
    return cell
  }

  // MARK: -  TableView Delegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
