//
//  DecryptTLV.h
//  DecrypTLVdemo
//
//  Created by 方正伟 on 2018/8/3.
//  Copyright © 2018年 方正伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DecryptTLV : NSObject

+ (NSDictionary *)decryptTLVToDict:(NSString *)tlvStr;

@end
