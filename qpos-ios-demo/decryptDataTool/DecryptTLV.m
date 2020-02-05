//
//  DecryptTLV.m
//  DecrypTLVdemo
//
//  Created by 方正伟 on 2018/8/3.
//  Copyright © 2018年 方正伟. All rights reserved.
//

#import "DecryptTLV.h"

@implementation DecryptTLV

+ (NSDictionary *)decryptTLVToDict:(NSString *)tlvStr{
    
   return [self decryptTLVData:tlvStr];
}

+ (NSMutableDictionary *)decryptTLVData:(NSString *)tlvStr{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (; ;) {
        
        if (tlvStr.length < [self currentCharacterNum:tlvStr] * 2) {
            return dict;
        }
        NSString *tagStr = [tlvStr substringToIndex:[self currentCharacterNum:tlvStr] * 2];
        tlvStr = [tlvStr substringFromIndex:[self currentCharacterNum:tlvStr] * 2];
        if (tlvStr.length < 3) {
            return dict;
        }
        NSString *lengStr = [tlvStr substringToIndex:2];
        NSString *hex2Str = [self getBinaryByHex:lengStr];
        int length = 0;
        
        if ([hex2Str hasPrefix:@"1"]) {
            //length有子字节
            hex2Str = [hex2Str substringFromIndex:1];
            //转为十进制
            int sonCharacterNum = (int)[self getDecimalByBinary:hex2Str];
            tlvStr = [tlvStr substringFromIndex:2];
            
            if (tlvStr.length < sonCharacterNum * 2) {
                return dict;
            }
            NSString *lengthStr = [tlvStr substringToIndex:sonCharacterNum * 2];
            length = [self ToHex:lengthStr];
            
            tlvStr = [tlvStr substringFromIndex:sonCharacterNum * 2];
            
        }else{
            
            length = [self ToHex:lengStr];
            tlvStr = [tlvStr substringFromIndex:2];
        }
        
        //获取value
        if (tlvStr.length < length * 2) {
            return dict;
        }
        NSString *strValue = [tlvStr substringToIndex:length * 2];
        
        [dict setValue:strValue forKey:tagStr];
        
        tlvStr = [tlvStr substringFromIndex:length * 2];
        
        if (tagStr.length == 2 && [self judgeIsCompoundTag:tagStr]) {
    
            tlvStr = [NSString stringWithFormat:@"%@%@",strValue,tlvStr];
        }
    }
    return nil;
}


+ (int)ToHex:(NSString*)tmpid{

    int result = 0;
    
    for (int i = 0; i < tmpid.length; i++) {
        
        NSString *str = [tmpid substringWithRange:NSMakeRange(i, 1)];
        int indexNum = (int)(tmpid.length - 1 - i);
        
        if ([str isEqualToString:@"A"]) {
            
            result  = result + 10 *pow(16, indexNum);
            
        }else if ([str isEqualToString:@"B"]){
            
            result  = result + 11 *pow(16, indexNum);
        }else if ([str isEqualToString:@"C"]){
            
            result  = result + 12 *pow(16, indexNum);
        }else if ([str isEqualToString:@"D"]){
            
            result  = result + 13 *pow(16, indexNum);
        }else if ([str isEqualToString:@"E"]){
            
            result  = result + 14 *pow(16, indexNum);
        }else if ([str isEqualToString:@"F"]){
            
            result  = result + 15 *pow(16, indexNum);
            
        }else{
            
            result = result + [str intValue]*pow(16, indexNum);
        }
    }
    return result;
}

//判断tag是两位还是四位
+ (NSInteger)currentCharacterNum:(NSString *)tlvStr{
    
    if ([self judgmentTagCharacterNum:tlvStr]) {
    
        NSString *newTLVstr = [tlvStr substringFromIndex:2];
        
        if ([self judgmentTagCharacterNum:newTLVstr]) {
            
        }else{
            
            return 2;
        }
    }else{
        
        return 1;
    }
    return 0;
}

//判断是复合tag还是非复合tag
+ (BOOL)judgeIsCompoundTag:(NSString *)tlvStr{
    //转为二进制
    NSString *hex2Str = [self getBinaryByHex:tlvStr];
    //截取后五位
    NSString *backFiveStr = [hex2Str substringFromIndex:2];
    
    if ([backFiveStr hasPrefix:@"1"]) {
        
        return YES;
    }
    return NO;
}

//判断是否有字节
+ (BOOL)judgmentTagCharacterNum:(NSString *)tlvStr{
    
    if (tlvStr.length < 3) {
        return NO;
    }
    //取前两位
    NSString *tagTwo = [tlvStr substringToIndex:2];
    //转为二进制
    NSString *hex2Str = [self getBinaryByHex:tagTwo];
    //截取后五位
    NSString *backFiveStr = [hex2Str substringFromIndex:3];
    
    if ([backFiveStr isEqualToString:@"11111"]) {
        
        return YES;
    }
    return NO;
}

//16进制转二进制
+ (NSString *)getBinaryByHex:(NSString *)hex {
    
    NSMutableDictionary *hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [hexDic setObject:@"0000" forKey:@"0"];
    [hexDic setObject:@"0001" forKey:@"1"];
    [hexDic setObject:@"0010" forKey:@"2"];
    [hexDic setObject:@"0011" forKey:@"3"];
    [hexDic setObject:@"0100" forKey:@"4"];
    [hexDic setObject:@"0101" forKey:@"5"];
    [hexDic setObject:@"0110" forKey:@"6"];
    [hexDic setObject:@"0111" forKey:@"7"];
    [hexDic setObject:@"1000" forKey:@"8"];
    [hexDic setObject:@"1001" forKey:@"9"];
    [hexDic setObject:@"1010" forKey:@"A"];
    [hexDic setObject:@"1011" forKey:@"B"];
    [hexDic setObject:@"1100" forKey:@"C"];
    [hexDic setObject:@"1101" forKey:@"D"];
    [hexDic setObject:@"1110" forKey:@"E"];
    [hexDic setObject:@"1111" forKey:@"F"];
    
    NSString *binary = @"";
    for (int i=0; i<[hex length]; i++) {
        
        NSString *key = [hex substringWithRange:NSMakeRange(i, 1)];
        NSString *value = [hexDic objectForKey:key.uppercaseString];
        if (value) {
            
            binary = [binary stringByAppendingString:value];
        }
    }
    return binary;
}

//二进制转十进制
+ (int)getDecimalByBinary:(NSString *)binary {
    
    int decimal = 0;
    for (int i=0; i<binary.length; i++) {
        
        NSString *number = [binary substringWithRange:NSMakeRange(binary.length - i - 1, 1)];
        if ([number isEqualToString:@"1"]) {
            
            decimal += pow(2, i);
        }
    }
    return decimal;
}

@end
