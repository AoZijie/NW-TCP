//
//  ViewController.swift
//  TempMonitor
//
//  Created by 田骜梓桀 on 2023/3/20.
//

import UIKit
import Network

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
//------------------------------------------------------------------------------------//
    
    //定义按钮变量
    static var TemperatureNum : Int = Int()
    static var TemperatureString : String = String()
    static var Door : String = String()
    
    //定义全局变量
    static var container : String = String()
    static var str1 : String = String()
    static var str2 : String = String()
    static var num : Int = Int()
    static var nwState : Bool = Bool()
    static var tempWarning : Bool = Bool()
    static var tempMax : String = String()
    static var tempMin : String = String()
    var selectedRow1 : String = String()
    var selectedRow2 : String = String()
    var tempEx1 = ["10","20","30","40","50","60","70","80","90","100","110","120","130","140","150","160","170","180","190","200","210","220","230","240","250","260","270","280","290","300","310","320","330","340","350","360","370","380","390","400","410","420","430","440","450","460","470","480","490","500","510","520","530","540","550","560","570","580","590","600"]
    var tempEx2 = ["0","10","20","30","40","50","60","70","80","90","100","110","120","130","140","150","160","170","180","190","200","210","220","230","240","250","260","270","280","290","300","310","320","330","340","350","360","370","380","390","400","410","420","430","440","450","460","470","480","490","500","510","520","530","540","550","560","570","580","590","600"]

    override func viewDidLoad() {
        PickerTemp?.delegate = self
        PickerTemp?.dataSource = self
        super.viewDidLoad()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(component == 0){
            return tempEx1.count
        }else{
            return tempEx2.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(component == 0) {
            return tempEx1[row]
        }else{
            return tempEx2[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(component == 0) {
            selectedRow1 = tempEx1[row]
        }else{
            selectedRow2 = tempEx2[row]
        }
    }
    
    
    //连接UI
    
    @IBOutlet weak var Confirm: UIButton!
    @IBOutlet weak var PickerTemp: UIPickerView!
    @IBOutlet weak var TempLimitation: UIButton!
    @IBOutlet weak var SystemStatus: UIButton!
    @IBOutlet weak var ConnectionState: UIButton!
    @IBOutlet weak var DoorState: UIButton!
    @IBOutlet weak var TemState: UIButton!
   
    
    //配置面板取消按钮
    @IBAction func PrefExit(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    //监控面板取消按钮
    @IBAction func MonExit(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
//-------------------------------------------面板按钮------------------------------------------//
    
    ///连接设备按钮
    @IBAction func ConnectButton(_ sender: UIButton) {
        //定义按钮触发窗口
        let Okay = UIAlertAction(title: "好", style: .cancel)
        let connectWirelessDevice = UIAlertController(title: "连接无线模块", message: "请稍等片刻，正在连接设备...", preferredStyle: .alert)
        connectWirelessDevice.addAction(Okay)
        self.present(connectWirelessDevice, animated: true)
        
        //调用连接方法并检查是否成功
        Connection().doHost()
        NWCheck()
        //延时函数
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            Processing().ConvertData()
            if ViewController.nwState == true {
                self.Confirm.isEnabled = true
                self.ConnectionState.setTitle("已连接", for: .normal)
            }else{
                self.ConnectionState.setTitle("连接失败", for: .normal)
            }
        }
    }
    
    
    ///更新数据按钮
    @IBAction func UpdateData(_ sender: UIButton) {
        //定义按钮触发窗口
        let Okay = UIAlertAction(title: "好", style: .cancel)
        let updateDataAlertPass = UIAlertController(title: "更新数据", message: "请稍等片刻，正在更新数据...", preferredStyle: .alert)
        let updateDataAlertFailed = UIAlertController(title: "不能执行此操作", message: "未连接设备", preferredStyle: .alert)
        updateDataAlertPass.addAction(Okay)
        updateDataAlertFailed.addAction(Okay)
        
        //检查网络连接并予以警告
        if ViewController.nwState == true {
            self.present(updateDataAlertPass, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.TemState.setTitle(ViewController.TemperatureString + "°C", for: .normal)
                self.TempLimitation.setTitle("\(ViewController.tempMin)°C - \(ViewController.tempMax)°C", for: .normal)
                if ViewController.tempWarning == true {
                    self.SystemStatus.isSelected = true
                    self.SystemStatus.setTitle("系统异常", for: .normal)
                    self.DoorState.setTitle("阀门开启", for: .normal)
                }else{
                    self.SystemStatus.setTitle("系统正常", for: .normal)
                    self.DoorState.setTitle("阀门关闭", for: .normal)
                }
            }
        }else{
            self.present(updateDataAlertFailed, animated: true)
        }
    }
    
//-----------------------------------------阀门控制按钮-----------------------------------------//
    
    //阀门打开按钮
    @IBAction func DoorOpenAlert(_ sender: UIButton) {
        //定义警告框
        let Confirm = UIAlertAction(title: "确定", style: .destructive)
        let OKay = UIAlertAction(title: "好", style: .default)
        let No = UIAlertAction(title: "取消", style: .cancel)
        let openAlert = UIAlertController(title: "警告", message: "如果确定此操作，进气阀会打开", preferredStyle: .alert)
        let openFailed = UIAlertController(title: "不能执行此操作", message: "进气阀当前已经打开", preferredStyle: .alert)
        let openSuccess = UIAlertController(title: "完成", message: "进气阀已打开", preferredStyle: .alert)
        let openDisabled = UIAlertController(title: "不能执行此操作", message: "未连接设备", preferredStyle: .alert)
        //添加按钮
//        openAlert.addAction(Confirm)
        openAlert.addAction(No)
        openFailed.addAction(OKay)
        openSuccess.addAction(OKay)
        openDisabled.addAction(OKay)
        
        //判断网络状态触发警告窗口
        if ViewController.nwState == false {
            self.present(openDisabled, animated: true)
            }else if ViewController.tempWarning == true{
                self.present(openFailed, animated: true)
        }else{
            self.DoorState.setTitle("阀门开启", for: .normal)
            self.present(openSuccess, animated: true)
        }
    }
    
    
    //阀门关闭按钮
    @IBAction func DoorCloseAlert(_ sender: UIButton) {
        //定义警告窗口
        let Confirm = UIAlertAction(title: "确定", style: .destructive)
        let OKay = UIAlertAction(title: "好", style: .default)
        let No = UIAlertAction(title: "取消", style: .cancel)
        let closeAlert = UIAlertController(title: "警告", message: "如果确定此操作，进气阀会关闭", preferredStyle: .alert)
        let closeFailed = UIAlertController(title: "不能执行此操作", message: "进气阀当前已经关闭", preferredStyle: .alert)
        let closeSuccess = UIAlertController(title: "完成", message: "进气阀已关闭", preferredStyle: .alert)
        let closeDisabled = UIAlertController(title: "不能执行此操作", message: "未连接设备", preferredStyle: .alert)
        //添加按钮
//        closeAlert.addAction(Confirm)
        closeAlert.addAction(No)
        closeFailed.addAction(OKay)
        closeSuccess.addAction(OKay)
        closeDisabled.addAction(OKay)
        
        //判断网络状态触发窗口
        if ViewController.nwState == false {
            self.present(closeDisabled, animated: true)
            }else if ViewController.tempWarning == true{
                self.present(closeSuccess, animated: true)
                self.DoorState.setTitle("阀门关闭", for: .normal)
        }else{
            self.present(closeFailed, animated: true)
        }
    }
    
    //确认温度阈值并转移数据
    @IBAction func TransferLimitationData(_ sender: Any) {
        ViewController.tempMax = selectedRow1
        ViewController.tempMin = selectedRow2
        print(ViewController.tempMax + "°C")
        print(ViewController.tempMin + "°C")
    }
}
