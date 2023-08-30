//
//  ConvertData.swift
//  TempMonitor
//
//  Created by 田骜梓桀 on 2023/4/22.
//

import Foundation
import Network

class Processing {
    
    //转换接收的文本
    func ConvertData(){
        ViewController.str1 = ViewController.container.replacingOccurrences(of: "Temp:", with: "")
        ViewController.str2 = ViewController.str1.replacingOccurrences(of: "C", with: "")
        ViewController.num = (ViewController.str2 as NSString).integerValue
        ViewController.TemperatureNum = ViewController.num
        ViewController.TemperatureString = String(ViewController.num)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.CheckingDoor()
        }
    }
    
    //判断温度阈值
    func CheckingDoor(){
        let a = (ViewController.tempMax as NSString).integerValue
        let b = (ViewController.tempMin as NSString).integerValue
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            if ViewController.TemperatureNum >= a {
                print(ViewController.TemperatureNum)
                ViewController.tempWarning = true
            }else{
                if ViewController.TemperatureNum <= b {
                    ViewController.tempWarning = true
                }else{
                    ViewController.tempWarning = false
                }
            }
        }
    }
}
