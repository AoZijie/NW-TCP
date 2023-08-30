//
//  AsServer.swift
//  TempMonitor
//
//  Created by 田骜梓桀 on 2023/4/7.
//

import Foundation
import Network

class Connection {
    //创建连接及队列
    var con : NWConnection = NWConnection(host: "192.168.4.1", port: 8080, using: .tcp)
    var queue = DispatchQueue(label: "Q1")
    
    func doHost() {
        //连接状态处理
        con.stateUpdateHandler = { (newState) in
            switch(newState) {
            case .ready:
                print("standby")
            case .failed(_):
                print("warning")
            default:
                break
            }
        }
        
        //启动连接
        con.start(queue: queue)
        
        //接收数据并转移到公共容器
        let headerLength: Int = 10
        con.receive(minimumIncompleteLength: headerLength, maximumLength: headerLength) {(content, context, isComplete, error) in
            let content = String(decoding: content!, as: UTF8.self)
            ViewController.container = content
        }
    }
}
