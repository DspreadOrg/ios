//
//  TLVParser.m
//  qpos-ios-demo
//
//  Created by fangzhengwei on 2021/11/16.
//  Copyright © 2021 Robin. All rights reserved.
//

#import "TLVParser.h"

@implementation TLVParser
+ (NSArray<TLV *> *)parse:(NSString *)tlv{
    return [self decryptTLVData:tlv];
}

+ (TLV *)searchTLV:(NSArray<TLV *> *)tlvList searchTag:(NSString *)searchTag{
    for (TLV *tlvTag in tlvList) {
        if ([tlvTag.tag caseInsensitiveCompare:searchTag] == NSOrderedSame) {
            return tlvTag;
        }
    }
    return nil;
}

+ (NSArray<TLV *> *)decryptTLVData:(NSString *)tlvStr{
    NSMutableArray<TLV *> *dict = [NSMutableArray array];
    for (; ;) {
        TLV *tlv = [TLV new];
        NSInteger tagNum = [self judgmentTagCharacterNum:tlvStr] * 2;
        if (!tagNum) {
            return dict.copy;
        }
        NSString *tagStr = [tlvStr substringToIndex:tagNum];
        tlvStr = [tlvStr substringFromIndex:tagNum];
        NSString *lengStr = @"";
        if (tlvStr.length >= 2) {
            lengStr = [tlvStr substringToIndex:2];
        }else{
            return dict.copy;
        }
        NSString *hex2Str = [self getBinaryByHex:lengStr];
        int length = 0;
        
        if ([hex2Str hasPrefix:@"1"]) {
            //length有子字节
            hex2Str = [hex2Str substringFromIndex:1];
            //转为十进制
            int sonCharacterNum = (int)[self getDecimalByBinary:hex2Str];
            tlvStr = [tlvStr substringFromIndex:2];
            
            if (tlvStr.length < sonCharacterNum * 2) {
                return dict.copy;
            }
            lengStr = [tlvStr substringToIndex:sonCharacterNum * 2];
            length = [self ToHex:lengStr];
            tlvStr = [tlvStr substringFromIndex:sonCharacterNum * 2];
        }else{
            length = [self ToHex:lengStr];
            tlvStr = [tlvStr substringFromIndex:2];
        }
        //获取value
        if (tlvStr.length < length * 2) {
            return dict.copy;
        }
        NSString *strValue = [tlvStr substringToIndex:length * 2];
//        [dict setValue:strValue forKey:tagStr];
        tlv.tag = tagStr;
        tlv.length = lengStr;
        tlv.value = strValue;
        [dict addObject:tlv];
        
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
    return [self judgmentTagCharacterNum:tlvStr];
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
+ (NSInteger)judgmentTagCharacterNum:(NSString *)tlvStr{
    NSInteger tagLen = 1;
    NSInteger index = 0;
    //取前两位
    NSString *tagTwo = @"";
    if (tlvStr.length > index + 2) {
        tagTwo = [tlvStr substringWithRange:NSMakeRange(index, 2)];
    }else{
        return 0;
    }
    index += 2;
    //转为二进制
    NSString *hex2Str = [self getBinaryByHex:tagTwo];
    //截取后五位
    NSString *backFiveStr = [hex2Str substringFromIndex:3];
    if ([backFiveStr isEqualToString:@"11111"]) {
        tagLen++;
        BOOL continueFlag = TRUE;
        while(continueFlag){
            if (tlvStr.length > index + 2) {
                tagTwo = [tlvStr substringWithRange:NSMakeRange(index, 2)];
            }else{
                continueFlag = false;
                break;
            }
            index += 2;
            //转为二进制
            hex2Str = [self getBinaryByHex:tagTwo];
            if([hex2Str hasPrefix:@"1"]){
                backFiveStr = [hex2Str substringFromIndex:1];
                if ([backFiveStr containsString: @"1"]) {
                    tagLen++;
                }else{
                    continueFlag = false;
                }
            }else{
                continueFlag = false;
            }
        }
    }
    return tagLen;
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
