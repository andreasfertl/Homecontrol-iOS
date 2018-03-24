//
//  ConfiguredMessageSensors.swift
//  HomeControl
//
//  Created by Andreas Fertl on 21.03.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation



struct ConfiguredMessageBasic : Codable{
    let type: String?
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
    }
}


