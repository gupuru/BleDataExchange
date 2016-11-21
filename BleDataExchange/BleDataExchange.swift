//
//  BleDataExchange.swift
//  BleDataExchange
//
//  Created by 新見晃平 on 2016/11/17.
//  Copyright © 2016年 kohei Niimi. All rights reserved.
//

import Foundation
import CoreBluetooth

public class BleDataExchange: NSObject, CBPeripheralManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var _serviceUUID: [CBUUID] = [CBUUID(string: "4ac5f234-5953-4371-8e36-1700282e4c54")]
    private var _readUUID: CBUUID = CBUUID(string: "8b74f39e-26f4-4121-ad81-2361a359fa24")
    private var _writeUUID: CBUUID = CBUUID(string: "4b54cd82-66cd-4678-ab0a-48e44a3f34ae")
    private var peripheralManager: CBPeripheralManager!
    private var peripheral: CBPeripheral!
    private var centralManager: CBCentralManager!
    private var characteristic: CBMutableCharacteristic!
    
    open var serviceUUID: String = "" {
        didSet {
            if serviceUUID == "" {
                serviceUUID = "4ac5f234-5953-4371-8e36-1700282e4c54"
            }
            _serviceUUID = []
            _serviceUUID.append(CBUUID(string: serviceUUID.lowercased()))
        }
    }
    
    open var readCharacteristicUUID: String = "" {
        didSet {
            if readCharacteristicUUID == "" {
                readCharacteristicUUID = "8b74f39e-26f4-4121-ad81-2361a359fa24"
            }
            _readUUID = CBUUID(string: readCharacteristicUUID.lowercased())
        }
    }
    
    open var writeCharacteristicUUID: String = "" {
        didSet {
            if writeCharacteristicUUID == "" {
                writeCharacteristicUUID = "4b54cd82-66cd-4678-ab0a-48e44a3f34ae"
            }
            _writeUUID = CBUUID(string: writeCharacteristicUUID.lowercased())
        }
    }
    
    open var initData: String = ""
    
    open var localNameKey: String = "ex"
    
    open var delegate: BleDataExchangeDelegate?
    
    open func start() {
        initPeripheral()
        initCentral()
    }
    
    open func stop() {
        stopAdvertise()
        
        self.centralManager.stopScan()
    }
    
    open func startPeripheral() {
        initPeripheral()
    }
    
    open func stopPeripheral() {
        stopAdvertise()
    }
    
    open func send(data: String) {
        let sendData = data.data(using: String.Encoding.utf8)
        self.characteristic.value = sendData;
        
        let result =  self.peripheralManager.updateValue(
            sendData!,
            for: self.characteristic,
            onSubscribedCentrals: nil)
        
        if result {
            delegate?.state(state: .PeripheralManagerUpdateSuccess)
        } else {
            delegate?.state(state: .PeripheralManagerUpdateFaild)
        }
    }
    
    // MARK: - init

    private func initPeripheral() {
        let peripheralQueue = DispatchQueue(label: "com.gupuru.BleDataExchange.peripheral")
        let peripheralOptions = [
            CBCentralManagerOptionRestoreIdentifierKey : "com.gupuru.BleDataExchange.peripheral.restore"
        ]
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: peripheralQueue, options: peripheralOptions)
    }
    
    private func initCentral() {
        let centralQueue = DispatchQueue(label: "com.gupuru.BleDataExchange.central")
        let centralOptions = [
            CBCentralManagerOptionRestoreIdentifierKey : "com.gupuru.BleDataExchange.central.restore"
        ]
        self.centralManager = CBCentralManager(delegate: self, queue: centralQueue, options: centralOptions)
    }
    
    // MARK: - CBCentralManagerDelegate
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
                let options: [String : Bool] = [
                    CBCentralManagerScanOptionAllowDuplicatesKey : false
                ]
                //start scan
                self.centralManager.scanForPeripherals(withServices: _serviceUUID, options: options)
        default:
            break
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.peripheral = peripheral
        // connrct device
        self.centralManager.connect(self.peripheral, options: nil)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        delegate?.state(state: .ConnectDeviceSuccess)
        peripheral.delegate = self
        //discover services
        peripheral.discoverServices(nil)
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate?.state(state: .ConnectDeviceFaild)
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
    }
    
    // MARK: - CBPeripheralDelegate
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            delegate?.bleDataExchangeError(error: error!)
            return
        }
        
        if !((peripheral.services?.count)! > 0) {
            delegate?.state(state: .NoServices)
            return
        }
        
        let services = peripheral.services!
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?)
    {
        if error != nil {
            delegate?.bleDataExchangeError(error: error!)
            return
        }
        
        if !((service.characteristics?.count)! > 0) {
            return
        }
        
        let characteristics = service.characteristics!
        
        for characteristic in characteristics {
            peripheral.setNotifyValue(
                true,
                for: characteristic)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral,
                    didUpdateNotificationStateFor characteristic: CBCharacteristic,
                    error: Error?)
    {
        if error != nil {
            delegate?.bleDataExchangeError(error: error!)
        } else {
            delegate?.state(state: .NotifySuccess)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?)
    {
        if error != nil {
            delegate?.bleDataExchangeError(error: error!)
            return
        }
        delegate?.receive(data: characteristic.value)
    }

    // MARK: - CBPeripheralManagerDelegate
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            self.publishservice()
        default:
            break
        }
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if error != nil {
            delegate?.bleDataExchangeError(error: error!)
            return
        }
        self.startAdvertise()
    }
    
    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if error != nil {
            delegate?.bleDataExchangeError(error: error!)
            return
        }
        delegate?.state(state: .AdvertiseSuccess)
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        request.value = self.characteristic.value
        // response request
        self.peripheralManager.respond(
            to: request,
            withResult: .success
        )
        delegate?.state(state: .ReceiveReadRequest)
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        //send init data
        send(data: initData)
        delegate?.state(state: .StartNotify)
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        delegate?.state(state: .StopNotify)
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        
    }
    
    // MARK: - Advertise
    
    private func startAdvertise() {
        let advertisementData = [CBAdvertisementDataLocalNameKey: localNameKey,
                                 CBAdvertisementDataServiceUUIDsKey: _serviceUUID
            ] as [String : Any]

        self.peripheralManager.startAdvertising(advertisementData)
    }
    
    private func stopAdvertise () {
        if let peripheral = self.peripheralManager {
            if peripheral.isAdvertising {
                peripheral.stopAdvertising()
            }
            peripheral.removeAllServices()
            self.peripheralManager = nil
        }
    }
    
    private func publishservice () {
        let service = CBMutableService(type: _serviceUUID[0], primary: true)
        
        self.characteristic = CBMutableCharacteristic(
            type: _readUUID,
            properties: [
                CBCharacteristicProperties.read,
                CBCharacteristicProperties.notify
            ],
            value: nil,
            permissions: [
                CBAttributePermissions.readable,
                CBAttributePermissions.writeable]
        )
        
        let characteristicWrite = CBMutableCharacteristic(
            type: _writeUUID,
            properties: [
                CBCharacteristicProperties.write
            ],
            value: nil,
            permissions: [CBAttributePermissions.writeable]
        )
        
        service.characteristics = [
            self.characteristic,
            characteristicWrite
        ]
        
        self.peripheralManager.add(service)

        let sendData = initData.data(using: String.Encoding.utf8)
        self.characteristic.value = sendData
    }

}
