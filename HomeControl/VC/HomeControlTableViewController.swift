//
//  HomeControlTableViewController.swift
//  HomeControl
//
//  Created by Andreas Fertl on 03.02.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import UIKit

protocol ReceiveMsgDelegate: class {
    func receivedMessage(message: Msg)
}

enum TableType: Int, Codable
{
    case LightSwitch
    case TempHumiditySensor
}

struct Elements
{
    let InternalId: Int
    let Name: String
    let type: TableType
    var subtitle: String
}

class HomeControlTableViewController: UITableViewController, ReceiveMsgDelegate {
    
    @IBOutlet var Table: UITableView!
//    var elements =   ["Obergeschoss", "Aussenlicht"]
//    var subtititle = ["aus",          "aus"]
//    var ineternalId = [21,             22]
    
    var elements: [Elements] = []
    var pm: ProgramManager?
    var buttonPressedDeleagte: ButtonPressed?

    override func viewDidLoad() {
        super.viewDidLoad()
        pm = ProgramManager(receiver: self)
        buttonPressedDeleagte = pm?.GetButtonProtocol()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return elements.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeControlCell", for: indexPath)

        // Configure the cell...
        if (indexPath.row < elements.count)
        {
            let element = elements[indexPath.row]
            
            cell.textLabel?.text = element.Name
            cell.detailTextLabel?.text = element.subtitle
            
            if element.type == TableType.LightSwitch {
                cell.accessoryType = .detailButton
            }
        }
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if (elements[indexPath.row].subtitle == "aus") {
            buttonPressedDeleagte?.buttonPress(index: elements[indexPath.row].InternalId, on: true)
            elements[indexPath.row].subtitle = "ein"
        } else {
            buttonPressedDeleagte?.buttonPress(index: elements[indexPath.row].InternalId, on: false)
            elements[indexPath.row].subtitle = "aus"
        }
        self.Table.reloadData()
    }
    
    func UpdateSubtitle(internalId: Int, update: String)
    {
        for index in 0..<elements.count {
            if elements[index].InternalId == internalId {
                elements[index].subtitle = update
            }
        }
        
        
        self.Table.reloadData()
    }

    func AddSensorUniquely(sensor: ConfiguredTempHumiditySensors)
    {
        var found : Bool = false

        for element in elements {
            if element.InternalId == sensor.InternalId {
                found = true; //already added
                break;
            }
        }
        if !found {
            elements.append(Elements(InternalId: sensor.InternalId, Name: sensor.Name, type: TableType.TempHumiditySensor, subtitle: "-.-"))
        }
    }

    func AddSensorsUniquely(sensors: [ConfiguredTempHumiditySensors])
    {
        for sensor in sensors {
            AddSensorUniquely(sensor: sensor)
        }
        self.Table.reloadData()
    }

    func AddLightUniquely(light: ConfiguredLight)
    {
        var found : Bool = false
        
        for element in elements {
            if element.InternalId == light.InternalId {
                found = true; //already added
                break;
            }
        }
        if !found {
            elements.append(Elements(InternalId: light.InternalId, Name: light.Name, type: TableType.LightSwitch, subtitle: "aus"))
        }
    }

    func AddLightsUniquely(lights: [ConfiguredLight])
    {
        for light in lights {
            AddLightUniquely(light: light)
        }
        
        self.Table.reloadData()
    }

    func receivedMessage(message: Msg) {

        if (message.commandType == CommandType.TempMessage)
        {
            if let tempHumiditySensor = message.value as? TempMessage {
                let str = "Temperature: " + String(describing: tempHumiditySensor.Temp) + ", Humidity: " + String(describing: tempHumiditySensor.Humidity)
                UpdateSubtitle(internalId: tempHumiditySensor.InternalId, update: str)
            }
        }
        else if (message.commandType == CommandType.ConfigurationMessage)
        {
            if let config = message.value as? ConfiguredMessageSensors {
                if config.tempHumiditySensors != nil {
                    AddSensorsUniquely(sensors: config.tempHumiditySensors!)
                }
            } else if let config = message.value as? ConfiguredLights {
                if config.lights != nil {
                    AddLightsUniquely(lights: config.lights!)
                }
            }

        }
    }
}




