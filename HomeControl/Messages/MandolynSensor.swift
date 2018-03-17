//
//  TempSensor.swift
//  HomeControl
//
//  Created by Andreas Fertl on 03.02.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation

struct MandolynSensor : Codable{
    let Id: Int?
    let Temp: Float?
    let Humidity: Int?

    enum CodingKeys: String, CodingKey {
        case Id
        case Temp
        case Humidity
    }
}

