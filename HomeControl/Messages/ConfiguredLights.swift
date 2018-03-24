//
//  ConfiguredLights.swift
//  HomeControl
//
//  Created by Andreas Fertl on 24.03.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation


struct ConfiguredLight : Codable{
    let InternalId: Int
    let Name: String
    let type: String = "Messanger.ConfiguredLight, Messanger"
    
    enum CodingKeys: String, CodingKey {
        case InternalId
        case Name
        case type = "$type"
    }
}

struct ConfiguredLights : Codable{
    var lights : [ConfiguredLight]?
    let type: String = "Messanger.ConfiguredLights, Messanger"
    
    enum CodingKeys: String, CodingKey {
        case lights
        case type = "$type"
    }
}

