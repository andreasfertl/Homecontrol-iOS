//
//  Command.swift
//  HomeControl
//
//  Created by Andreas Fertl on 25.02.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation


enum Command: Int, Codable
{
    case set
    case get
    case answer
    case any
}

enum CommandType: Int, Codable
{
    case Subscribe
    case Run
    case LogMessage
    case LogLevel
    case Stop
    case LightControl
    case BluetoothDevPressence
    case CodeswitchButtonMessage
    case TempMessage
    case SunriseSunset
    case SSHClientControl
    case MusicControl
    case MusicMessageState
    case ConfigurationMessage
    case MusicMessageVolume
    case ALIVE_MESSAGE
    case ArctecSwitch
    case MandolynSensor
}

