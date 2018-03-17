//
//  HomeControlTableViewController.swift
//  HomeControl
//
//  Created by Andreas Fertl on 03.02.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import UIKit

protocol ReceiveMsgDelegate: class {
    func receivedMessage(message: MandolynSensor)
}

class HomeControlTableViewController: UITableViewController, ReceiveMsgDelegate {
    
    @IBOutlet var Table: UITableView!
    var elements = ["Wohnzimmer", "Arbeitszimmer", "Bod", "Aussen"]
    var subtititle = ["-.-", "-.-", "-.-", "-.-"]
    var pm: ProgramManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pm = ProgramManager(receiver: self)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return elements.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeControlCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = elements[indexPath.row]
        cell.detailTextLabel?.text = subtititle[indexPath.row]

        return cell
    }
    
    func AddCellString(stringToAdd: String)
    {
        elements.append(stringToAdd)
    }

    func Update(index: Int, update: String)
    {
        subtititle[index] = update
        self.Table.reloadData()
    }

    func receivedMessage(message: MandolynSensor) {

        if message.Humidity != nil && message.Id != nil && message.Temp != nil
        {
            let str = "Temperature: " + String(describing: message.Temp!) + ", Humidity: " + String(describing: message.Humidity!)
            
            if (message.Id! == 21)
            {
                Update(index: 2, update: str)
            } else if (message.Id! == 13)
            {
                Update(index: 1, update: str)
            } else if (message.Id! == 12)
            {
                Update(index: 3, update: str)
            } else if (message.Id! == 11)
            {
                Update(index: 0, update: str)
            }
        }
    }
}




