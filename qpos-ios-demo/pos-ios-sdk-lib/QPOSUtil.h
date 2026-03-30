//
//  Util.h
//  qpossdk
//
//  Created by wangxu on 13-11-5.
//  Copyright (c) 2013年 xiaochengdong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QPOSUtil : NSObject

+(NSString*)byteArray2Hex: (NSData *)data;
+(NSData *)HexStringToByteArray: (NSString*)hexString;
+(NSString*)getHexString: (NSData *)b;
+(NSData *)IntToHex: (NSInteger)i;
+(void)printHexString: (NSData *)b;
+(NSInteger)byteArrayToInt: (NSData *)data;
+(Byte)XorByteStream: (Byte *)b SteamStartOffset:(NSInteger)startPos StreamLen:(NSInteger)Len;
+(NSData *)get: (Byte *)array ArrayOffset:(NSInteger)offset;
+(NSData *)get: (Byte *)array ArrayOffset:(NSInteger)offset ToGetLength:(NSInteger)length;
+(void)turnUpVolume: (NSInteger)factor;
+(NSString *)asciiFormatString:(NSData *)adata;
+(NSData *)stringFormatTAscii:(NSString *)aString;
+(BOOL)isPureInt:(NSString*)string;
+(BOOL)isPureLong:(NSString*)string;
+(BOOL)isPureFloat:(NSString*)string;
+(NSString *)gbString:(NSString *)string;
+(NSData *)restructureBMP:(NSString *)origin width:(int)width height:(int)height;
+(NSDictionary *)anlysData:(NSString *)tlv;
+(NSDictionary *)anlysData_hh:(NSString *)tlv;
+(NSData *)ecb:(NSData *)aData;
+(NSData *)bcd2asc:(NSData*)aData;
+(NSDictionary *)anlysData_lp:(NSString *)tlv;
+(NSData *)IntToHexOne: (NSInteger)i;
+(NSString *)IntToHexStrTwo: (NSInteger)i;
+(NSDictionary *)anlysPaddingCommonData:(NSInteger)encryMode data:(NSString *)tlv;
+(NSDictionary *)anlysPaddingCommonDataByPosid:(NSInteger)encryMode data:(NSString *)tlv qposid:(NSString*)inPosId;
+(NSString *)getReverseData:(NSString *)adStr;
+(int)ToHex:(NSString*)tmpid;
+(NSArray<NSString *> *)getArray:(NSString *)a;
+(NSArray<NSString *> *)getReverseValue:(NSArray<NSString *> *)a;
+(NSString *)getHexByDecimal:(NSInteger)decimal;
+(int)hex2dec:(NSString *)hex;
+(BOOL)checkStringAllZero:(NSString*)string;
+(NSString *)int2Byte:(NSInteger)intValue;
+(NSData *)int2ByteData:(NSInteger)intValue;
//+(NSString *)encryptedPinBlock:(NSString *)pin pan:(NSString *)pan random:(NSString *)random aesKey:(NSString *)aesKey;
+(NSString *)pinxCreator:(NSString *)pan withPinv:(NSString *)pinv;
+(NSString *)byteComplement:(NSString *)data1 data2:(NSString *)data2 dataLen:(NSInteger)dataLen;
+(void)getMacField:(NSString *)paras randomKey:(NSString *)randomKey posid:(NSString *)posid;
+(NSString *)IntToHexStrOne: (NSInteger)i;
+(NSString *)getWriteData:(NSString *)data block:(NSString *)block;
+(void)sleepMs: (NSInteger)msec;
+(NSString *)ToHexStr:(long long int)tmpid;
+(NSArray *)getIntArray:(NSString *)a;
+(BOOL)stringContainsNonHexCharacters:(NSString *)string;
@end
