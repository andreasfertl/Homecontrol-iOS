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

enum Section: Int {
    case Local
    case Sensors
    case Lights
    
    var description : String {
        switch self {
        case .Local: return "Local"
        case .Sensors: return "Sensors"
        case .Lights: return "Lights"
        }
    }
    static let count: Int = {
        var max: Int = 0
        while let _ = Section(rawValue: max) { max += 1 }
        return max
    }()
}

enum TableType: Int, Codable {
    case LightSwitch
    case TempHumiditySensor
    case WakeOnLan
}

class Elements {
    let InternalId: Int
    let Name: String
    let type: TableType
    var subtitle: String?
    let section: Section //corresponding section
    var uiswitch: UISwitch? //potential switch
    
    init(internalId: Int, name: String, type: TableType, subtitle: String, section: Section) {
        self.InternalId = internalId
        self.Name = name
        self.type = type
        self.subtitle = subtitle
        self.section = section
    }
    init(internalId: Int, name: String, type: TableType, subtitle: String, section: Section, uiSwitch: UISwitch) {
        self.InternalId = internalId
        self.Name = name
        self.type = type
        self.subtitle = subtitle
        self.section = section
        self.uiswitch = uiSwitch
    }
}


class HomeControlTableViewController: UITableViewController, ReceiveMsgDelegate {
    
    @IBOutlet var Table: UITableView!
    var elements: [Elements] = []
    
    var pm: ProgramManager?
    var buttonPressedDeleagte: ButtonPressed?
    
    // This is the size of our header sections that we will use later on.
    let SectionHeaderHeight: CGFloat = 30
    
    //no statusbar at all
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pm = ProgramManager(receiver: self)
        buttonPressedDeleagte = pm?.GetButtonProtocol()
        
        //configure local WOL element
        elements.append(Elements(internalId: 1, name: "WOL", type: TableType.WakeOnLan, subtitle: "DevPC", section: Section.Local, uiSwitch: GenerateSwitch(internalId: 1)))
        
        //testdata
        elements.append(Elements(internalId: 12, name: "Living Room", type: TableType.TempHumiditySensor, subtitle: "not received yet", section: Section.Sensors))
        elements.append(Elements(internalId: 11, name: "Outside", type: TableType.TempHumiditySensor, subtitle: "not received yet", section: Section.Sensors))
        elements.append(Elements(internalId: 21, name: "Shed", type: TableType.TempHumiditySensor, subtitle: "not received yet", section: Section.Sensors))
        
        AddLightUniquely(light: ConfiguredLight(InternalId: 1001, Name: "Upstairs"))
        AddLightUniquely(light: ConfiguredLight(InternalId: 1002, Name: "Outside"))
        AddLightUniquely(light: ConfiguredLight(InternalId: 1011, Name: "Master Bedroom Ms."))
        AddLightUniquely(light: ConfiguredLight(InternalId: 1008, Name: "Master Bedroom Mr."))
        AddLightUniquely(light: ConfiguredLight(InternalId: 1003, Name: "Master Bedroom"))

        AddLightUniquely(light: ConfiguredLight(InternalId: 1004, Name: "Kitchen"))
        AddLightUniquely(light: ConfiguredLight(InternalId: 1009, Name: "Kitchen window"))

        AddLightUniquely(light: ConfiguredLight(InternalId: 1005, Name: "Living Room stand"))
        AddLightUniquely(light: ConfiguredLight(InternalId: 1006, Name: "Living Room sideboard"))
        AddLightUniquely(light: ConfiguredLight(InternalId: 1007, Name: "Living Room piano"))

        AddLightUniquely(light: ConfiguredLight(InternalId: 1010, Name: "Office"))
        
        //elements.append(Elements(internalId: 1001, name: "Upstairs", type: TableType.LightSwitch, subtitle: "off", section: Section.Lights))
        //elements.append(Elements(internalId: 1002, name: "Outside", type: TableType.LightSwitch, subtitle: "off", section: Section.Lights))
        //elements.append(Elements(internalId: 1003, name: "Master Bedroom", type: TableType.LightSwitch, subtitle: "off", section: Section.Lights))
        //elements.append(Elements(internalId: 1010, name: "Office", type: TableType.LightSwitch, subtitle: "off", section: Section.Lights))

        //        elements.append(Elements(internalId: 1, name: "Küche", type: TableType.LightSwitch, subtitle: "aus", section: Section.Lights))
//        elements.append(Elements(internalId: 1, name: "Schlafzimmer", type: TableType.LightSwitch, subtitle: "aus", section: Section.Lights))
//        elements.append(Elements(internalId: 1, name: "Bad", type: TableType.LightSwitch, subtitle: "aus", section: Section.Lights))
//        elements.append(Elements(internalId: 1, name: "Arbeitszimmer", type: TableType.LightSwitch, subtitle: "aus", section: Section.Lights))
//        elements.append(Elements(internalId: 1, name: "Hems", type: TableType.LightSwitch, subtitle: "aus", section: Section.Lights))
//        elements.append(Elements(internalId: 1, name: "Utebod", type: TableType.LightSwitch, subtitle: "aus", section: Section.Lights))
    }
    
    func Start() {
        pm?.Start()
    }
    
    func Stop() {
        pm?.Stop()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let section = Section(rawValue: section) {
            return CountNumberOfElementsInSection(section: section)
        }
        return 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: SectionHeaderHeight))
        view.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: SectionHeaderHeight))
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        guard let tableSection = Section(rawValue: section) else { return view }
        label.text = tableSection.description
        view.addSubview(label)
        return view
    }
    
    
    @objc func switchChanged(_ sender : UISwitch!) {
        //special case for local IDs
        if sender.tag == 1 {
            localWOL()
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
                sender.setOn(false, animated: true)
                self.Table.reloadData()
            }
        } else {
            buttonPressedDeleagte?.buttonPress(index: sender.tag, on: sender.isOn)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeControlCell", for: indexPath)

        // Configure the cell...
        guard let section = Section(rawValue: indexPath.section) else { return cell }
        let elements = GenerateSubsection(section: section, elements: self.elements)

        if indexPath.row < elements.count {
            let element = elements[indexPath.row]
            cell.textLabel?.text = element.Name
            if element.subtitle != nil {
                cell.detailTextLabel?.text = element.subtitle
            }
            //button to activate?
            if element.uiswitch != nil {//element.type == TableType.LightSwitch || element.type == TableType.WakeOnLan {
                cell.accessoryView = element.uiswitch
            }
            else {
                cell.accessoryView = .none
            }
        }
        return cell
    }
}


//handling
extension HomeControlTableViewController {
    
    func GenerateSwitch(internalId: Int) -> UISwitch {
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(false, animated: true)
        switchView.tag = internalId
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        switchView.onTintColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)

        return switchView
    }
    
    func GenerateSubsection(section: Section, elements: [Elements]) -> [Elements] {
        var subsection = [Elements]()
        
        for element in elements {
            if element.section == section {
                subsection.append(element)
            }
        }
        
        return subsection
    }

    func IsSection(section: Section, element: Elements) -> Bool {
        if (element.section == section) {
            return true
        } else {
            return false
        }
    }
    
    func CountNumberOfElementsInSection(section: Section) -> Int {
        var count = 0
        
        for element in elements {
            if IsSection(section: section, element: element) {
                count = count + 1
            }
        }
        return count
    }
    
    func AddSensorUniquely(sensor: ConfiguredTempHumiditySensors) {
        var found : Bool = false
        
        for element in elements {
            if element.InternalId == sensor.InternalId {
                found = true; //already added
                break;
            }
        }
        if !found {
            elements.append(Elements(internalId: sensor.InternalId, name: sensor.Name, type: TableType.TempHumiditySensor, subtitle: "-.-", section: Section.Sensors))
        }
    }
    
    func AddSensorsUniquely(sensors: [ConfiguredTempHumiditySensors]) {
        for sensor in sensors {
            AddSensorUniquely(sensor: sensor)
        }
        self.Table.reloadData()
    }
    
    func AddLightUniquely(light: ConfiguredLight) {
        var found : Bool = false
        
        for element in elements {
            if element.InternalId == light.InternalId {
                found = true; //already added
                break;
            }
        }
        if !found {
            elements.append(Elements(internalId: light.InternalId, name: light.Name, type: TableType.LightSwitch, subtitle: "", section: Section.Lights, uiSwitch: GenerateSwitch(internalId: light.InternalId)))
        }
    }
    
    func AddLightsUniquely(lights: [ConfiguredLight]) {
        for light in lights {
            AddLightUniquely(light: light)
        }
        
        self.Table.reloadData()
    }
    
    func localWOL() {
        let computer = Awake.Device(MAC: "94:C6:91:15:E6:D1", BroadcastAddr: "255.255.255.255", Port: 9)
        _ = Awake.target(device: computer)
    }
    
    func UpdateSubtitle(internalId: Int, update: String) {
        for index in 0..<elements.count {
            if elements[index].InternalId == internalId {
                elements[index].subtitle = update
            }
        }
        self.Table.reloadData()
    }

    
    func UpdateSwitchState(internalId: Int, on: Bool) {
        for index in 0..<elements.count {
            if elements[index].InternalId == internalId {
                elements[index].uiswitch?.setOn(on, animated: true)
            }
        }
    }

    func receivedMessage(message: Msg) {
        
        if (message.commandType == CommandType.MandolynSensor) {
            if let tempHumiditySensor = message.value as? MandolynSensor {
                let str = "Temperature: " + String(describing: tempHumiditySensor.Temp!) + ", Humidity: " + String(describing: tempHumiditySensor.Humidity!)
                UpdateSubtitle(internalId: tempHumiditySensor.Id!, update: str)
            }
        } else if (message.commandType == CommandType.ConfigurationMessage) {
            if let config = message.value as? ConfiguredMessageSensors {
                if config.tempHumiditySensors != nil {
                    AddSensorsUniquely(sensors: config.tempHumiditySensors!)
                }
            } else if let config = message.value as? ConfiguredLights {
                if config.lights != nil {
                    AddLightsUniquely(lights: config.lights!)
                }
            }
        } else if (message.commandType == CommandType.LightControl) {
            if let msg = message.value as? LightMessage {
                if msg.lightState != nil {
                    if msg.lightState == LightState.Off {
                        UpdateSwitchState(internalId: msg.Id!, on: false)
                    } else {
                        UpdateSwitchState(internalId: msg.Id!, on: true)
                    }
                }
            }
        }
    }

    
}



