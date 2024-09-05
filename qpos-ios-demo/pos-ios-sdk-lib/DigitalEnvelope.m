//
//  DigitalEnvelope.m
//  qpos-ios-demo
//
//  Created by 方正伟 on 9/3/24.
//  Copyright © 2024 Robin. All rights reserved.
//

#import "DigitalEnvelope.h"
#import "RSA.h"
#import "QPOSUtil.h"

@implementation DigitalEnvelope
+ (NSString *)getEncryptedDataByPublicKey:(NSString *)tmkStr publicKey:(NSString *)publicKey{
    //    self.getEncryptedData = dataBlock;
    if (tmkStr == nil || publicKey == nil) {
        return @"";
    }
    
//    if (tmkStr.length != 32 && tmkStr.length != 48) {
//        NSLog(@"tmk length is incorrect, tmk= %@",tmkStr);
//        return @"";
//    }
    
    if (publicKey.length != 256 && publicKey.length != 512) {
        NSLog(@"publicKey length is incorrect, publicKey= %@",publicKey);
        return @"";
    }
    return [self getEncryptedData:tmkStr publicKey:publicKey];
}

+ (NSString *)getEncryptedData:(NSString *)tmkStr publicKey:(NSString *)publicKey{
    NSString *enData = [self getDigitalEnvelopStrByKey:tmkStr publicKey:publicKey keyIndex:0];
    return enData;
}

+ (NSString *)getDigitalEnvelopStrByKey:(NSString *)tmkStr publicKey:(NSString *)publicKey keyIndex:(NSInteger)keyIndex{
    
    NSString *token = tmkStr;
    NSString *tmkTag = @"00"; // 04代表更新TMK
    //NSString *keyIndexStr = [QPOSUtil byteArray2Hex:[QPOSUtil IntToHexOne:keyIndex]];
    NSString *tmkLength = [QPOSUtil int2Byte:token.length/2];
    NSString *message = [[tmkTag stringByAppendingString:tmkLength] stringByAppendingString:token];
    
    NSString *command = @"01030000";
    NSString *messageLenth = [self int2Byte2:message.length/2];
    NSString *message2 = [command stringByAppendingString:messageLenth]; // 2 bytes length
    message2 = [message2 stringByAppendingString:@"0000"]; // 2字节保留位
    message2 = [message2 stringByAppendingString:message];
    NSLog(@"message2:%@",message2);
    
    //设备公钥
    NSLog(@"publicKey: %@",publicKey);
    NSData *publicKeyData = [QPOSUtil HexStringToByteArray:[@"00" stringByAppendingString:publicKey]];
    SecKeyRef publicSecKey = [RSA publicKeyDataWithMod:publicKeyData exp:[QPOSUtil HexStringToByteArray:@"010001"]];
    if (publicSecKey == nil) {
        return @"";
    }
    
    NSData *tempData = [RSA encryptWithKey:publicSecKey plainData:[self getTdeskey] padding:kSecPaddingNone];
    if (tempData == nil) {
        return @"";
    }
    NSString *encrypedTdesKey = [QPOSUtil byteArray2Hex:tempData];
    NSString *encrypedMessage = [self encrypt:message2];
    NSString *toSha1Message = [encrypedTdesKey stringByAppendingString:encrypedMessage];
    NSString *signedMessage = [self sign:toSha1Message];
    if(signedMessage == nil){
        return @"";
    }
   
   NSInteger len = (encrypedTdesKey.length + encrypedMessage.length + signedMessage.length)/2;
   NSString *lenStr = [self int2Byte2:len];
   lenStr = [lenStr stringByAppendingString:@"00"]; //保留位
    if (publicKey.length == 256) {
        lenStr = [lenStr stringByAppendingString:@"00"]; //保留位
    }else if(publicKey.length == 512){
        lenStr = [lenStr stringByAppendingString:@"80"]; //保留位
    }
   NSLog(@"lenStr: %@", lenStr);
    
   NSString *result = @"";
   result = [[[[result stringByAppendingString:lenStr] stringByAppendingString:encrypedTdesKey] stringByAppendingString:encrypedMessage] stringByAppendingString:signedMessage];
   NSLog(@"result: %@ \n encrypedTdesKey: %@\n encrypedMessage: %@\n signedMessage: %@\n ",result,encrypedTdesKey,encrypedMessage,signedMessage);
    
   NSInteger blockSize = result.length/512;
   if (result.length % 512 != 0) {
       ++blockSize;
   }
    
    NSInteger count = blockSize *512 - result.length;
    for (int i = 0; i< count; i++) {
        result = [result stringByAppendingString:@"F"];
    }
    NSLog(@"result: %@",result);
    return result;
}

+ (NSData *)getTdeskey{
    Byte byte[] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
    return [[NSData alloc] initWithBytes:byte length:16];
}

+ (NSString *)encrypt:(NSString *)message{
    //数据处理
    NSString *lenBytes1 = [QPOSUtil int2Byte:message.length/2];
    NSString *lenBytes2 = [QPOSUtil int2Byte:0];
    NSString *packagedMessage = [[lenBytes1 stringByAppendingString:lenBytes2] stringByAppendingString:message];
    
    NSInteger blockSize = packagedMessage.length/16;
    if (packagedMessage.length % 16 != 0) {
        ++blockSize;
    }
    
    NSInteger paddingSize = blockSize * 16 - packagedMessage.length;
    for (NSInteger i = 0; i< paddingSize ;i++) {
       packagedMessage = [packagedMessage stringByAppendingString:@"F"];
    }
    
    //获取到加密数据
    NSString *encryptedMess = @"";
    for (NSInteger i = 0; i< blockSize ;i++) {
        NSData *temp = [QPOSUtil HexStringToByteArray:[packagedMessage substringWithRange:NSMakeRange(i*16, 16)]];
        NSData *temp2 = [RSA DESOperation:kCCEncrypt algorithm:kCCAlgorithm3DES keySize:kCCKeySize3DES data:temp key:[self getTdeskey]];
        encryptedMess = [encryptedMess stringByAppendingString:[QPOSUtil byteArray2Hex:temp2]];
    }
    NSLog(@"encryptedMess: %@",encryptedMess);
    return encryptedMess;
}

// Using the RSA private key to sign the specified message
+ (NSString *)sign:(NSString *)content{
    SecKeyRef privateKeyRef = [RSA addPrivateKey1:@"MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDSSvwKDrn71RrFw2aX8T0KzSZpOsll2cjA+XyUWb/K1u+WarKOjdP6wj26NDPrmgKuCfEcqhqRax8VxIFd59DMbYIjSkPh3C4NHyT704lxnbmW/h2gS1bZcZb9QppTjsk8C7xkOsXkcW0XtSpgzRGuIGUelc8HSp6UETIaz/uggpPO6Mo1dA4qK958R+e+vaRrELCl8uy2N74nqrQ61Y5VfF5gy9ujHt/Yn75ZvFQ6kxFwNmMYWn6QbvegBQ8/LBf/q5UPLu1k9R3dmDuJqhxfqBm9LSlZ8QHGAs+yjUnhSdcNjTE/fp49OlzfR0wlv8Frf+ctXDXUz7WFHq6lYS8HAgMBAAECggEBAL8LJCG28ztXhHT5aXDL1hrD+QtMPr7qtTiq7oSPbG/IB+zsjb54FoYOhKlu12RIi/q0SXkzB+PoH1tVI/m9qbCuI7YPt8+uiZ+eFak5qfmvwnTr8to213W/fd4i7bTPWP3V45Zi1nkMmoEZMqCybEd2YqcAjg4fuiTl4lD9damAkOTsZe803iUfQRqJMXrwV+WBJDF+ATbJ3NTbqDzfsww9jmdNPAh0NlpYbLeFiL8S/t6hjziQgESjW9lCFlCJO3eXCPH0imepRDZz3CW684MYh0g+50JLjBMa9dX1EEaQxtcFXzksb1CRKPNEpO83kuzCAjVosSCJll65+uy7KLECgYEA8vgw0/h7FqFOuHAQldCCPiX54UQDQ7xGZj1MOWeK21BTp6YxPFeXUzWMPdfM546nrNCr39ErMv6v6nnqmRDMG7TU629OLCZusv91p3IgXc5/6nRkXyRAtfKRzMnwPnq19qV7Pr4ZsTrzSVA8qEZ5EDcSXufzizttRj3VNLAum+MCgYEA3ZIqgRItfurZhvlhvdZRQ7nkb2reyOLHj1G9/YKr2Uehhq321oxpe1ut62ZzM+3adfYlMYwjGyYiFOldcgQrmNf2rSnMu8qPwdGoJOSW8HqF1QmNEXF4IYWeovNvuVHQVX+1mH3aSlXjlxziYEwpVS35ZCfQXbbB65EAN+Sb0Y0CgYB32vjzR8socbBMiXOVA8OL9t3aQtu9aT3tJ2XXl31HDMwHkpMNKkRK1sp0o2TAAX4zYMi4Yw2FXV/YMgYJNeEJ9d1muoR8gQTwpdYbINBYlgpB1OLCkDafyqYjuKYbnBrxLdarL8mqxOLIkp0pgYIs/o3AZXmdgFY6ZTwsfpCvcwKBgQCbe2dyPXRJnLna2oM5OPy7vuXLPb5qT6FkNCNTk2/OQFLb9JXDhrK6iuInzzPGXAGyR3FgLIuyEHdYH06gpMaHMf17FFsD6KgqhVot0W8N/5yMm3AvrmVzeJWSmatr6zp71Ot0v9P/1/emYfGFS8yxZlqcasfwC0BXcuApWLXzPQKBgQCe2FMXiqmcrVzUOjOvvYZojm1ENvXSlHrzY1KnknS4WMAYpWhde8fq+rcegqsCvTrmHjlvPg0uCGE2pwQ9rffdEVXyAYZsoVlqj0bOLMci8Znr5QC9HHbZwZZiIU0FL6i8XuNQKkFe04/9vKpOKvE6TIaDbluuUKjMcd2+pbIQdg=="];
    if (!privateKeyRef) { NSLog(@"添加私钥失败"); return  nil; }
    NSData *sha1Data = [QPOSUtil getSha1Bytes:[QPOSUtil HexStringToByteArray:content]];
    unsigned char *sig = (unsigned char *)malloc(256);
    size_t sig_len;
    NSLog(@"sha1Data: %@",[QPOSUtil byteArray2Hex:sha1Data]);
    NSLog(@"privateKeyRef: %@",privateKeyRef);
    OSStatus status = SecKeyRawSign(privateKeyRef, kSecPaddingPKCS1SHA1, [sha1Data bytes], CC_SHA1_DIGEST_LENGTH, sig, &sig_len);
    NSLog(@"sig: %s",sig);
    if (status != noErr) {
        NSLog(@"加签失败:%d",(int)status);
        return nil;
    }
    NSData *outData = [NSData dataWithBytes:sig length:sig_len];
    free(sig);
    return [QPOSUtil byteArray2Hex:outData];
}

+ (NSString *)int2Byte2:(NSInteger)intValue {
    Byte b[] = {0,0};
    Byte r[] = {0,0};

   for(int i = 0; i < 2; ++i) {
       b[i] = (Byte)(intValue >> 8 * (1 - i) & 255);
   }
   r[1] = b[0];
   r[0] = b[1];
   return [QPOSUtil byteArray2Hex:[[NSData alloc] initWithBytes:r length:2]];
}

@end
