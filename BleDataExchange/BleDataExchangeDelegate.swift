//
//  BleDataExchangeDelegate.swift
//  BleDataExchange
//
//  Created by 新見晃平 on 2016/11/18.
//  Copyright © 2016年 kohei Niimi. All rights reserved.
//

import Foundation

public protocol BleDataExchangeDelegate {
    func bleDataExchangeError(error: Error)
    func receive(error: Error)
    func state(state: DataExChangeState)
}
