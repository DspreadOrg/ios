//
//  ParseXMLTool.h
//  Swift-demo
//
//  Created by 方正伟 on 2018/9/14.
//  Copyright © 2018年 方正伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QPOSTestFramework/GDataXMLNode.h>
#import <QPOSTestFramework/TagApp.h>
#import <QPOSTestFramework/TagCapk.h>
typedef enum : NSUInteger {
    EMVAppXMl,
    EMVCapkXMl,
} EMVXML;

@interface ParseXMLTool : NSObject

+ (NSArray *)requestXMLData:(EMVXML)appOrCapk;
@end
