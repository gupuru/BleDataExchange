//
//  Manager.swift
//  BleDataExchange
//
//  Created by 新見晃平 on 2016/11/18.
//  Copyright © 2016年 kohei Niimi. All rights reserved.
//

import Foundation

public enum DataExChangeState {
    case AdvertiseSuccess
    case PeripheralManagerUpdateSuccess
    case PeripheralManagerUpdateFaild
    case StartNotify
    case StopNotify
    case ReceiveReadRequest
    case ConnectDeviceSuccess
    case ConnectDeviceFaild
    case NoServices
    case NotifySuccess
}
