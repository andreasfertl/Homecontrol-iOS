//
//  LightMessage.swift
//  HomeControl
//
//  Created by Andreas Fertl on 24.02.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation

enum LightState: Int, Codable
{
    case Off
    case On
}

struct LightMessage : Codable {
    let Id: Int?
    let lightState: LightState?

    enum CodingKeys: String, CodingKey {
        case Id
        case lightState
    }
}



