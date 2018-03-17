//
//  Destination.swift
//  HomeControl
//
//  Created by Andreas Fertl on 25.02.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation

enum Destination: Int, Codable
{
    case NotSet = 0
    case Server
    case MappingManager
    case ConsoleHandler
    case ConsoleLogger
    case FileLogger
    case SonosManager
    case PhilipsHue
    case BluetoothManager
    case Telldus
    case TelldusLive
    case TCPManager1
    case Remote
    case SunriseSunset
    case SSHClientManager
    case VoiceControlManager
    case ConfigurationManager
    case TCPManager2
    case TCPManager3
    
    case Subscribers = 0xFFFFFFFE
    case Broadcast = 0xFFFFFFFF
};
