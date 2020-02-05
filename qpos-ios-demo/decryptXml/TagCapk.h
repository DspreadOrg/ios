//
//  TagCapk.h
//  qpos-ios-demo
//
//  Created by 方正伟 on 2018/8/8.
//  Copyright © 2018年 Robin. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *RID = @"_9F06";
static NSString *Public_Key_Index = @"_9F22";
static NSString *Public_Key_Module = @"DF02";
static NSString *Public_Key_CheckValue = @"DF03";
static NSString *Pk_exponent = @"DF04";
static NSString *Expired_date = @"DF05";
static NSString *Hash_algorithm_identification = @"DF06";
static NSString *Pk_algorithm_identification = @"DF07";

@interface TagCapk : NSObject

@property (nonatomic, copy) NSString *Rid;

@property (nonatomic, copy) NSString *Public_Key_Index;

@property (nonatomic, copy) NSString *Public_Key_Module;

@property (nonatomic, copy) NSString *Public_Key_CheckValue;

@property (nonatomic, copy) NSString *Pk_exponent;

@property (nonatomic, copy) NSString *Expired_date;

@property (nonatomic, copy) NSString *Hash_algorithm_identification;

@property (nonatomic, copy) NSString *Pk_algorithm_identification;

@end
