//
//  ViewController.h
//  SmartPeripheral
//
//  Created by Sandeep on 23/06/15.
//  Copyright (c) 2015 H. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface ViewController : UIViewController<CBPeripheralManagerDelegate, UITextFieldDelegate>
{
    CBMutableCharacteristic *rx;
    NSMutableString *str;
}
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;

@end

