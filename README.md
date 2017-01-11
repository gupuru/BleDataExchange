# BleDataExchange

Data exchange library using BLE.

# How to use

```
github "gupuru/BleDataExchange"
```

# Usage

## Start

```swift
    let bleDataExchange: BleDataExchange = BleDataExchange()
    bleDataExchange.start()
```

## Stop

```swift
    let bleDataExchange: BleDataExchange = BleDataExchange()
    bleDataExchange.stop()
```

## Send Data

```swift
    let bleDataExchange: BleDataExchange = BleDataExchange()
    bleDataExchange.send(data: "data")
```

## Delegate

```swift

    func bleDataExchangeError(error: Error) {
        //error
    }
    
    func receive(data: Data?) {
        // Receive data
    }
    
    func state(state: DataExChangeState) {
        // connection state
    }
    
```

## Sample

```swift

class ViewController: UIViewController, BleDataExchangeDelegate {
        
    private let bleDataExchange: BleDataExchange = BleDataExchange()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bleDataExchange.delegate = self
        bleDataExchange.initData = "initData"
        bleDataExchange.serviceUUID = "uuid"
        bleDataExchange.readCharacteristicUUID = "uuid"
        
        bleDataExchange.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

```

# License

```
The MIT License (MIT)

Copyright (c) 2017 Kohei Niimi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```