//
//  BTDeviceFinder.h
//  Test
//
//  Created by wangxu on 13-11-8.
//  Copyright (c) 2013年 XiaoLonghui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class VPosBluetooth;
@class VPosBluetooth2Mode;


@protocol BluetoothDelegate<NSObject>

@optional
-(void)onBluetoothName:(NSString *)bluetoothName;
-(void)finishScanQPos;
@end

@protocol BluetoothDelegateNew<NSObject>

@optional
-(void)onBluetoothNameNew:(NSString *)bluetoothName;
-(void)finishScanQPosNew;
@end

@protocol BluetoothDelegate2Mode<NSObject>

@optional
-(void)onBluetoothName2Mode:(NSString *)bluetoothName;
-(void)finishScanQPos2Mode;
-(void)bluetoothIsPowerOff2Mode;
-(void)bluetoothIsPowerOn2Mode;
@end


@protocol BluetoothDelegateBLE<NSObject>

@optional
-(void)onBluetoothName2Mode:(NSString *)bluetoothName;
-(void)finishScanQPos2Mode;
-(void)bluetoothIsPowerOff2Mode;
-(void)bluetoothIsPowerOn2Mode;
@end


@interface BTDeviceFinder : NSObject

-(void)scanQPos: (NSInteger)timeout;
-(NSArray*)getAllOnlineQPosName;
-(void)stopQPos;
-(void)setBluetoothDelegate:(id<BluetoothDelegate>)aDelegate;


//new bluetooth sdk
//-(void)scanQPosNew: (NSInteger)timeout;
//-(NSArray*)getAllOnlineQPosNameNew;
//-(void)stopQPosNew;
//-(void)setBluetoothDelegateNew:(id<BluetoothDelegateNew>)aDelegate;


//bluetooth 2Mode
-(void)scanQPos2Mode: (NSInteger)timeout;
-(NSArray*)getAllOnlineQPosName2Mode;
-(void)stopQPos2Mode;
-(void)setBluetoothDelegate2Mode:(id<BluetoothDelegate2Mode>)aDelegate;
-(CBManagerState)getCBCentralManagerState;

//VPosBluetoothBLE
-(void)scanQPosBLE: (NSInteger)timeout;
-(NSArray*)getAllOnlineQPosNameBLE;
-(void)stopQPosBLE;
-(void)setBluetoothDelegateBLE:(id<BluetoothDelegateBLE>)aDelegate;
-(CBManagerState)getBLECBCentralManagerState;
@end





