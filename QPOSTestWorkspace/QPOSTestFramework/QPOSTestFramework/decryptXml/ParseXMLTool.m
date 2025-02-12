//
//  ParseXMLTool.m
//  Swift-demo
//
//  Created by 方正伟 on 2018/9/14.
//  Copyright © 2018年 方正伟. All rights reserved.
//

#import "ParseXMLTool.h"

@implementation ParseXMLTool
+ (NSArray *)requestXMLData:(EMVXML)appOrCapk {
    
    NSString *xml_Path = [[NSBundle mainBundle] pathForResource:@"emv_profile_tlv_20180717" ofType:@"xml"];
    
    NSData *xml_data = [[NSData alloc] initWithContentsOfFile:xml_Path];;
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:xml_data error:NULL];
    GDataXMLElement *rootElement = document.rootElement;
    NSMutableArray *modelArray = [NSMutableArray array];
    for (GDataXMLElement *videoElement in rootElement.children) {
        if (appOrCapk == EMVAppXMl) {
            if ([videoElement.name isEqualToString:@"app"]) {
                TagApp *video = [[TagApp alloc] init];
                for (GDataXMLNode *attribute in videoElement.attributes) {
                    [video setValue:attribute.stringValue forKey:attribute.name];
                }
                for (GDataXMLElement *subVideoElement in videoElement.children) {
                    [video setValue:subVideoElement.stringValue forKey:subVideoElement.name];
                }
                [modelArray addObject:video];
            }
        }else{
            if ([videoElement.name isEqualToString:@"capk"]) {
                TagCapk *video = [[TagCapk alloc] init];
                for (GDataXMLNode *attribute in videoElement.attributes) {
                    [video setValue:attribute.stringValue forKey:attribute.name];
                }
                for (GDataXMLElement *subVideoElement in videoElement.children) {
                    [video setValue:subVideoElement.stringValue forKey:subVideoElement.name];
                }
                [modelArray addObject:video];
            }
        }
    }
    return modelArray.copy;
}
@end
