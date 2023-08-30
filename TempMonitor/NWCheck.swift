//
//  NWCheck.swift
//  TempMonitor
//
//  Created by 田骜梓桀 on 2023/4/23.
//

import Foundation
import Network

public func NWCheck(){
    var queue : DispatchQueue
    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    
    monitor.pathUpdateHandler = { path in
        if path.status == .satisfied {
            ViewController.nwState = true
        }else{
            ViewController.nwState = false
        }
    }
    queue = DispatchQueue(label: "Q2")
    monitor.start(queue: queue)
}
