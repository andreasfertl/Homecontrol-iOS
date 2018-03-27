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
    let maxReadLength = 16512
    var rxMsg: String = ""
    var rxFullLine: String = ""
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
    
    private func write(stringToSend: String)
    {
        let data = stringToSend.data(using: .utf8)!
        _ = data.withUnsafeBytes { outputStream.write($0, maxLength: data.count) }
    }

    func sendJsonMsg(msgToSend: String?)
    {
        if (msgToSend != nil){
            write(stringToSend: msgToSend! + "\r\n")
        }
    }

    func sendMsg(msg: Msg?)
    {
        if (msg != nil){
            do {
                let jsonMsg = try JSONEncoder().encode(msg)
                let jsonString = String(data: jsonMsg, encoding: .utf8)
                if jsonString != nil{
                    sendJsonMsg(msgToSend: jsonString)
                }
            }
            catch let error
            {
                print(error)
            }
        }
    }

}

extension TCPSocket: StreamDelegate {
    
    func printFile(s:String) {
        
        //#if DEBUG
        //var error:NSError? = nil
        let path = "/Users/andreasfertl/dump.txt"
        //var dump = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)!
        //"\(dump)\n\(s)".writeToFile(path, atomically:true, encoding:NSUTF8StringEncoding, error:&error)
        let s = s + "\r\n"
        do {
            let dump =  try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
            try  "\(dump)\n\(Date()):\(s)".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
        }
        catch let error {
            print(error)
        }

        //#endif
    }

    private func getStringFromBuffer(buffer: UnsafeMutablePointer<UInt8>, index: Int, oldIndex: Int) -> String {
        
        let tmpBufferLengt = index+1
        var tmpbuffer = [UInt8]()
        
        for idx in 0..<tmpBufferLengt {
            tmpbuffer.append(buffer[oldIndex+idx])
        }
        tmpbuffer.append(0x00)

        return String(cString: tmpbuffer)
    }

    
    private func readLines(stream: InputStream) -> Array<String> {
        var linesToReturn = [String]()
        var receivedFullLine = false
        var oldIndex = 0

        while stream.hasBytesAvailable {
            receivedFullLine = false
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength+1)
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
            
            if numberOfBytesRead < 0 {
                if let _ = stream.streamError {
                    break
                }
            }
            buffer[numberOfBytesRead] = 0x00
            oldIndex = 0
            
            //did we already recieve a full line?
            var tmpIndex = 0
            for index in 0..<numberOfBytesRead {
                if buffer[index] == 0x0A {
                    //a full line
                    let fullLine = rxFullLine + getStringFromBuffer(buffer: buffer, index: index, oldIndex: oldIndex)
                    linesToReturn.append(fullLine)

                    rxFullLine = "" //reset line
                    receivedFullLine = true
                    oldIndex = index + 1 //pointing to next charachter
                }
                else {
                    receivedFullLine = false // just means we received another line in this buffer
                    tmpIndex = index
                }
            }
            if !receivedFullLine {
                //we didn´t receive a full line in this round - store all the bytes for later receive
                rxFullLine = rxFullLine + getStringFromBuffer(buffer: buffer, index: tmpIndex, oldIndex: oldIndex)
            }
            
            buffer.deallocate(capacity: maxReadLength+1)
        }
        
        return linesToReturn
    }
    
    private func convertLineToMsg(line: String) -> Msg?
    {
        //Construct the "Message" objects out of the line
        do {
            let convertedMsg = try JSONDecoder().decode(Msg.self, from: line.data(using: .utf8)!)
            printFile(s:"OK")
            printFile(s:line)
            return convertedMsg
        }
        catch let error {
            printFile(s:"NOT OK")
            printFile(s:line)
            print(error)
            return nil
        }
    }
    
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            let lines = readLines(stream: aStream as! InputStream)
            for line in lines {
                let msg = convertLineToMsg(line: line)
                if msg != nil {
                    delegate?.receivedMessage(message: msg!)
                }
            }
        case Stream.Event.endEncountered:
            print("end encountered received")
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


