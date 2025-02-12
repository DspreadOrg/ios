//
//  TLVParser.h
//  qpos-ios-demo
//
//  Created by fangzhengwei on 2021/11/16.
//  Copyright © 2021 Robin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QPOSTestFramework/TLV.h>
NS_ASSUME_NONNULL_BEGIN

@interface TLVParser : NSObject
+ (NSArray<TLV *> *)parse:(NSString *)tlv;
+ (TLV *)searchTLV:(NSArray<TLV *> *)tlvList searchTag:(NSString *)searchTag;
@end

NS_ASSUME_NONNULL_END
