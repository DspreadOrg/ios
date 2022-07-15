//
//  ParseXMLTool.h
//  Swift-demo
//
//  Created by 方正伟 on 2018/9/14.
//  Copyright © 2018年 方正伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"
#import "TagApp.h"
#import "TagCapk.h"
typedef enum : NSUInteger {
    EMVAppXMl,
    EMVCapkXMl,
} EMVXML;

@interface ParseXMLTool : NSObject

+ (NSArray *)requestXMLData:(EMVXML)appOrCapk;
@end
