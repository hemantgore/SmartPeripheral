//
//  ViewController.m
//  SmartPeripheral
//
//  Created by Sandeep on 23/06/15.
//  Copyright (c) 2015 H. All rights reserved.
//

#import "ViewController.h"
#define RBL_SERVICE_UUID                    @"713d0000-503e-4c75-ba94-3148f18d941e"
#define RBL_TX_UUID                         @"713d0003-503e-4c75-ba94-3148f18d941e"
#define RBL_RX_UUID                         @"713d0002-503e-4c75-ba94-3148f18d941e"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *startAdvertising;

@property (weak, nonatomic) IBOutlet UIButton *updateValueForTemp;
@property (weak, nonatomic) IBOutlet UITextView *debugTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.debugTextView.text = @"";
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    NSLog(@"self.peripheralManager powered on.");
    
    
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    NSLog(@"didReceiveWriteRequests");
    
    CBATTRequest*       request = [requests  objectAtIndex: 0];
    NSData*             request_data = request.value;
    CBCharacteristic*   write_char = request.characteristic;
    
    uint8_t buf[request_data.length];
    [request_data getBytes:buf length:request_data.length];
    
    NSMutableString *temp = [[NSMutableString alloc] init];
    for (int i = 0; i < request_data.length; i++) {
        [temp appendFormat:@"%c", buf[i]];
    }
    
    if (str == nil) {
        str = [NSMutableString stringWithFormat:@"%@\n", temp];
    } else {
        [str appendFormat:@"%@\n", temp];
    }
    

    
    //[peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}
-(int) decimalIntoHex:(char) number
{
    char ge  =number/10*16;
    char shi =number%10;
    int total =ge +shi;
    return total;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startStopAdvertising:(UIButton*)sender{
    if(sender.tag==1){//Already ON, set it OFF
        sender.tag = 0;
        [sender setTitle:@"Start Advertising" forState:UIControlStateNormal];
        [self.peripheralManager removeAllServices];
        [self.peripheralManager stopAdvertising];
    }else{//Alreay OFF, set to ON
        [sender setTitle:@"Stop Advertising" forState:UIControlStateNormal];
        sender.tag = 1;
        CBMutableCharacteristic *tx = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:RBL_TX_UUID] properties:CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsWriteable];
        rx = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:RBL_RX_UUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
        
        CBMutableService *s = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:RBL_SERVICE_UUID] primary:YES];
        s.characteristics = @[tx, rx];
        
        [self.peripheralManager addService:s];
        
        NSDictionary *advertisingData = @{CBAdvertisementDataLocalNameKey : @"iPhone", CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:RBL_SERVICE_UUID]]};
        [self.peripheralManager startAdvertising:advertisingData];
    }
    
}
- (IBAction)updateValue:(id)sender{
    
    uint8_t send[] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
    /*
     4.3.1 System Message Format
     MSGID|MSGTYP|NODEID|VCSID|CMDTYP||CMD||CMDPKT|PRI|TIMSTMP
     */
    //    uint8_t send[20];
    send[0]=[self decimalIntoHex:1];
    send[1]=0xB0;//MSG Type-0xB0:Sys, 0xB1:HW,0xB2:info, 0xB3:ACT
    send[2]=0x00;//5 bit, used for H/w msg type: 0xFD
    send[3]=0xC3;
    send[4]=0xA0;//CMD type, 0xA0:SET, 0xA1:GET, 0xA2:ACT
    send[5]=0xA0;//CMD,e,g: SetSysMod:0xEC
    send[6]=0x01; // 0x01:Cycling
    send[7]=0x01;//Priority: (0x01)in HEX==1 in Decimal
    send[8]=[self decimalIntoHex:[[NSDate date] timeIntervalSince1970]];// Get Sencond in since, convert ot HEX
    NSData *data = [[NSData alloc] initWithBytes:send length:9];
    //    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.peripheralManager updateValue:data forCharacteristic:rx onSubscribedCentrals:nil];
}
@end
