//
//  TLV.h
//  qpos-ios-demo
//
//  Created by fangzhengwei on 2021/11/16.
//  Copyright © 2021 Robin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TLV : NSObject
@property (nonatomic,copy)NSString *tag;
@property (nonatomic,copy)NSString *length;
@property (nonatomic,copy)NSString *value;
@end

NS_ASSUME_NONNULL_END
