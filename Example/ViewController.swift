//
//  ViewController.swift
//  Example
//
//  Created by 新見晃平 on 2016/11/17.
//  Copyright © 2016年 kohei Niimi. All rights reserved.
//

import UIKit
import BleDataExchange

class ViewController: UIViewController, BleDataExchangeDelegate {
    
    @IBOutlet weak var messageTextField: UITextField!
    
    private let bleDataExchange: BleDataExchange = BleDataExchange()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bleDataExchange.delegate = self
        bleDataExchange.initData = "rgb"
        bleDataExchange.serviceUUID = "4ac5f234-5953-4371-8e36-1700282e4c54"
        bleDataExchange.readCharacteristicUUID = "8B74F39E-26F4-4121-AD81-2361A359FA24"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    @IBAction func startTouchUpInside(_ sender: UIButton) {
        bleDataExchange.start()
    }
    
    @IBAction func stopTouchupInside(_ sender: UIButton) {
        bleDataExchange.stop()
    }
    
    @IBAction func sendMessageTouchupInside(_ sender: UIButton) {
        bleDataExchange.send(data: messageTextField.text!)
    }
    
    func bleDataExchangeError(error: Error) {
        print(error)
    }
    
    func receive(data: Data?) {
        if let sendData = data {
            print(NSString(data: sendData, encoding: String.Encoding.utf8.rawValue)!)
        }
    }
    
    func state(state: DataExChangeState) {
        print(state)
    }
    
}

