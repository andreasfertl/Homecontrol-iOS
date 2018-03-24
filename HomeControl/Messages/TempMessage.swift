//
//  ConfiguredLights.swift
//  HomeControl
//
//  Created by Andreas Fertl on 24.03.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation

//
//  ConfiguredMessageSensors.swift
//  HomeControl
//
//  Created by Andreas Fertl on 21.03.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation

struct TempMessage : Codable{
    let InternalId : Int
    let Temp : Float
    let Humidity : Int
    let Name : String
    let type: String = "Messanger.TempMessage, Messanger"
    
    enum CodingKeys: String, CodingKey {
        case InternalId
        case Temp
        case Humidity
        case Name
        case type = "$type"
    }
}

