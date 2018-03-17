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

//extension MandolynSensor {
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: Msg.CodingKeys.self)
//        let nestedValues = try values.nestedContainer(keyedBy: Msg.CodingKeys.self, forKey: Msg.CodingKeys.Value)
//
//        Id = try values.decodeIfPresent(Int.self, forKey: .Id)
//        Temp  = try values.decodeIfPresent(Float.self, forKey: .Temp)
//        Humidity = try values.decodeIfPresent(Int.self, forKey: .Humidity)
//    }
//}

