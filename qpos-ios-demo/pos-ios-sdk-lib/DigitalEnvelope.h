//
//  DigitalEnvelope.h
//  qpos-ios-demo
//
//  Created by 方正伟 on 9/3/24.
//  Copyright © 2024 Robin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DigitalEnvelope : NSObject
+ (NSString *)getEncryptedDataByPublicKey:(NSString *)tmkStr publicKey:(NSString *)publicKey;
@end

NS_ASSUME_NONNULL_END
