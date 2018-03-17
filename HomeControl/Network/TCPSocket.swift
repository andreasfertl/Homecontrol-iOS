//
//  TCPSocket.swift
//  HomeControl
//
//  Created by Andreas Fertl on 10.02.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation
import UIKit

class TCPSocket: NSObject {
    var inputStream: InputStream!
    var outputStream: OutputStream!
    let maxReadLength = 4096
    var lastRxedMsg: String = ""
    weak var delegate: ReceiveMsgDelegate?
    
    init(receiver: ReceiveMsgDelegate) {
        delegate = receiver
    }
    
    func setupNetworkCommunication(connectIp: String, connectPort: UInt32) {

        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           connectIp as CFString,
                                           connectPort,
                                           &readStream,
                                           &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        
        inputStream.schedule(in: .current, forMode: .commonModes)
        outputStream.schedule(in: .current, forMode: .commonModes)
        
        inputStream.open()
        outputStream.open()
    }
    
    func write(stringToSend: String)
    {
        let data = stringToSend.data(using: .ascii)!
        _ = data.withUnsafeBytes { outputStream.write($0, maxLength: data.count) }
    }
}

extension TCPSocket: StreamDelegate {
    
    private func readAvailableBytes(stream: InputStream) -> MandolynSensor?
    {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
            
            if numberOfBytesRead < 0 {
                if let _ = stream.streamError {
                    break
                }
            }
            
            //Construct the "Message" object
            let msg = String(bytesNoCopy: buffer, length: numberOfBytesRead, encoding: .ascii, freeWhenDone: true)
            if msg != nil {
                do {
                    let convertedMsg = try JSONDecoder().decode(Msg.self, from: msg!.data(using: .ascii)!)

                    if convertedMsg.commandType == CommandType.MandolynSensor {
                        return convertedMsg.value as? MandolynSensor;
                    }
                    else {
                        return nil;
                    }
                }
                catch let error {
                    print(error)
                }
            }
            return nil;
        }
        return nil;
    }

    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            let msg = readAvailableBytes(stream: aStream as! InputStream)
            if msg != nil {
                delegate?.receivedMessage(message: msg!)
            }
        case Stream.Event.endEncountered:
            print("new message received")
        case Stream.Event.errorOccurred:
            print("error occurred")
        case Stream.Event.hasSpaceAvailable:
            print("has space available")
        default:
            print("some other event...")
            break
        }
    }
}


