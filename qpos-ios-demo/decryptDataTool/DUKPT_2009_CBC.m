//
//  DUKPT_2009_CBC.m
//  DUKPT_2009_CBC_OC
//
//  Created by zengqingfu on 15/3/12.
//  Copyright (c) 2015年 zengqingfu. All rights reserved.
//

#import "DUKPT_2009_CBC.h"
#import <AFNetworking/AFNetworking.h>
static const char *HEXES = "0123456789ABCDEF";
#define gIv  @"00000000"
#define kSecrectKeyLength 24
@implementation DUKPT_2009_CBC

+(void)decryptDataWithAWS:(NSString *)ksn ciphertext:(NSString *)ciphertext resultBlock:(void (^)(BOOL isSuccess,NSDictionary *decryptionResult))resultBlock{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSDictionary *params = @{
        @"keyIdentifier": @"arn:aws:payment-cryptography:us-east-1:750226982526:key/rmzbbqjxd7euatrh",
        @"ciphertext": ciphertext,
        @"dukptData": @{
          @"ksn": ksn,
          @"mode": @"CBC",
          @"keyDerivationType": @"TDES_2KEY"
        }
      };
    NSString *url = @"https://ypparbjfugzgwijijfnb.supabase.co/functions/v1/dukpt-decrypt";
    [manager POST:url parameters:params headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress: %@", uploadProgress.description);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        resultBlock(true,responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 网络错误处理
        resultBlock(false,error.userInfo);
    }];
}

+(void)getTR31BlockFromAWS:(NSString *)ksn resultBlock:(void (^)(BOOL isSuccess,NSDictionary *tr31Block))resultBlock{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSDictionary *params = @{
        @"exportKeyIdentifier": @"arn:aws:payment-cryptography:us-east-1:750226982526:key/rmzbbqjxd7euatrh",
        @"wrappingKeyIdentifier": @"arn:aws:payment-cryptography:us-east-1:750226982526:key/2u53xd3gnk5v3qkv",
        @"keySerialNumber": ksn
    };
    NSString *url = @"https://ypparbjfugzgwijijfnb.supabase.co/functions/v1/export-tr31";
    [manager POST:url parameters:params headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress: %@", uploadProgress.description);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject: %@",responseObject);
        resultBlock(true,responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 网络错误处理
        NSLog(@"error: %@",error.userInfo);
        resultBlock(false,error.userInfo);
    }];
}

+(NSData *)generateIPEKwithKSNStr:(NSString *)ksn bdk:(NSString *)bdk{
    return [self GenerateIPEKksn:[self parseHexStr2Byte:ksn] bdk:[self parseHexStr2Byte:bdk]];
}

///*对
+ (NSData *) GenerateIPEKksn:(NSData *) ksn bdk: (NSData *)bdk
{
    
    Byte temp2[8] = {0};
    Byte result[16] = {0};
    Byte temp[8] = {0};

    Byte keyTemp[16] = {0};
    
    memcpy(keyTemp, [bdk bytes], 16);
    memcpy(temp, [ksn bytes], 8);
    
    temp[7] &= 0xE0;
    //TDes_Decrypt(temp, temp2, keyTemp);
   //temp2 = [[DUKPT_2009_CBC TriDesDecryptionKey:bdk dec:ksn] getbytes];
   // NSData* decryptedBlock = [DUKPT_2009_CBC DESOperation:kCCDecrypt algorithm:kCCAlgorithm3DES keySize:kCCKeySize3DES data:[self dataFromString:block] key:key];
    
    NSData *encReult = [DUKPT_2009_CBC DESOperation:kCCEncrypt algorithm:kCCAlgorithm3DES keySize:kCCKeySize3DES data:ksn key:bdk];
    [encReult getBytes:temp2 length:8];
   // temp2 = TriDesEncryption(keyTemp,temp);
    memcpy(result, temp2, 8);
    bzero(temp2, 8);
    keyTemp[0] ^= 0xC0;
    keyTemp[1] ^= 0xC0;
    keyTemp[2] ^= 0xC0;
    keyTemp[3] ^= 0xC0;
    keyTemp[8] ^= 0xC0;
    keyTemp[9] ^= 0xC0;
    keyTemp[10] ^= 0xC0;
    keyTemp[11] ^= 0xC0;
    //TDes_Decrypt(temp, temp2, keyTemp);
    //temp2 = [DUKPT_2009_CBC TriDesDecryptionKey:keyTemp dec:temp];
    
    NSData *key_tempDat2 = [NSData dataWithBytes:keyTemp length:16];
    NSData *decDat2 = [NSData dataWithBytes:temp length:8];
    
    NSData *encReult2 = [DUKPT_2009_CBC DESOperation:kCCEncrypt algorithm:kCCAlgorithm3DES keySize:kCCKeySize3DES data:decDat2 key:key_tempDat2];
    [encReult2 getBytes:temp2 length:8];
    //temp2 = TriDesEncryption(keyTemp,temp);
    memcpy(&result[8], temp2, 8);
    
    //System.arraycopy(temp2, 0, result, 8, 8);
    NSData *resultDat = [NSData dataWithBytes:result length:16];
    
//    free(result);
//    free(temp);
//    free(keyTemp);
//    
    return resultDat;
}

//对
+ (NSData *)GetDUKPTKeyKsn:(NSData *) ksn ipek: (NSData *)ipek
{

//    NSLog(@"ksnXX = %@", ksn);
//    NSLog(@"ipekXX = %@", ipek);
    int shift = 0;
    
    Byte *ksnB = (Byte *)[ksn bytes];
    
    Byte  key[16] = {0};
    memcpy(key, [ipek bytes], 16);
    //System.arraycopy(ipek, 0, key, 0, 16);
    
    Byte  cnt[3] = {0};
    Byte temp[8] = {0};
    
    cnt[0] = (Byte)(ksnB[7] & 0x1F);
    cnt[1] = ksnB[8];
    cnt[2] = ksnB[9];
    
    memcpy(temp, &ksnB[2], 6);
    //System.arraycopy(ksn, 2, temp, 0, 6);
    temp[5] &= 0xE0;
    
   // NSData *tempDD = [NSData dataWithBytes:key length:16];
    
    
    shift = 0x10;
    while (shift > 0)
    {
        if ((cnt[0] & shift) > 0)
        {
            temp[5] |= shift;
            NRKGP(key, temp);
        }
        shift >>= 1;
    }
    shift = 0x80;
    while (shift > 0)
    {
        if ((cnt[1] & shift) > 0)
        {
            temp[6] |= shift;
            NRKGP(key, temp);
        }
        shift >>= 1;
    }
    shift = 0x80;
    while (shift > 0)
    {
        if ((cnt[2] & shift) > 0)
        {
    
            temp[7] |= shift;
            NRKGP(key, temp);

            
        }
        shift >>= 1;
    }
    NSData *keyDat = [NSData dataWithBytes:key length:16];

    return keyDat;
    //return key;
}
//对
void NRKGP(Byte *key, Byte *ksn)
{
    NSInteger i = 0;
    
    Byte temp[8] = {0};
    Byte key_temp[8] = {0};
    Byte key_l[8] = {0};
    Byte key_r[8] = {0};
    //key_l = (Byte *)malloc(8);
    //key_r = (Byte *)malloc(8);

    memcpy(key_temp, key, 8);
    //System.arraycopy(key, 0, key_temp, 0, 8);
    for (i = 0; i < 8; i++)
        temp[i] = (Byte)(ksn[i] ^ key[8 + i]);
    //TDes_Decrypt(temp, key_r, key_temp);
    
    
   // key_r = [DUKPT_2009_CBC TriDesEncryptionKey:key_temp dec:temp];
    //NSData* decryptedBlock = [self DESOperation:kCCDecrypt algorithm:kCCAlgorithm3DES keySize:kCCKeySize3DES data:[self dataFromString:block] key:key];
    
    NSData *key_tempDat = [NSData dataWithBytes:key_temp length:8];
    NSData *decDat = [NSData dataWithBytes:temp length:8];
    
    NSData *encReult = [DUKPT_2009_CBC DESOperation:kCCEncrypt algorithm:kCCAlgorithmDES keySize:kCCKeySizeDES data:decDat key:key_tempDat];
    [encReult getBytes:key_r length:8];
    
    //key_r = TriDesEncryption(key_temp,temp);
    for (i = 0; i < 8; i++)
        key_r[i] ^= key[8 + i];
    
    key_temp[0] ^= 0xC0;
    key_temp[1] ^= 0xC0;
    key_temp[2] ^= 0xC0;
    key_temp[3] ^= 0xC0;
    key[8] ^= 0xC0;
    key[9] ^= 0xC0;
    key[10] ^= 0xC0;
    key[11] ^= 0xC0;
    
    for (i = 0; i < 8; i++)
        temp[i] = (Byte)(ksn[i] ^ key[8 + i]);
    //TDes_Decrypt(temp, key_l, key_temp);
    //key_l = [DUKPT_2009_CBC TriDesEncryptionKey:key_temp dec:temp];
    
    NSData *key_tempDat2 = [NSData dataWithBytes:key_temp length:8];
    NSData *decDat2 = [NSData dataWithBytes:temp length:8];
    
    NSData *encReult2 = [DUKPT_2009_CBC DESOperation:kCCEncrypt algorithm:kCCAlgorithmDES keySize:kCCKeySizeDES data:decDat2 key:key_tempDat2];
    [encReult2 getBytes:key_l length:8];
    
    NSData *tempDD = [NSData dataWithBytes:key length:16];
    NSData *tempDD2 = [NSData dataWithBytes:key_l length:8];
    
    //key_l = TriDesEncryption(key_temp,temp);
    for (i = 0; i < 8; i++)
        key[i] = (Byte)(key_l[i] ^ key[8 + i]);
    memcpy(&key[8], key_r, 8);
    //System.arraycopy(key_r, 0, key, 8, 8);
    
//    free(temp);
//    free(key_l);
//    free(key_r);
//    free(key_temp);

}

+(NSData *)GetDataKeyWithKSNstr:(NSString *)ksn ipek:(NSString *)ipek{
    return [self GetDataKeyVariantKsn:[self parseHexStr2Byte:ksn] ipek:[self parseHexStr2Byte:ipek]];
}

+ (NSData *)GetDataKey:(NSString *) ksn bdk: (NSString *)bdk{
    NSData *byte_ksn = [self parseHexStr2Byte:ksn];
    NSData *byte_bdk = [self parseHexStr2Byte:bdk];
    NSData *ipek = [self GenerateIPEKksn:byte_ksn bdk:byte_bdk];
    NSData *dataKey = [DUKPT_2009_CBC GetDataKeyKsn:byte_ksn ipek:ipek];
    return dataKey;
}

+(NSData* )GetDataKeyVariantKsnWithKSNstr:(NSString *)ksn ipek:(NSData *)ipek{
    return [self GetDataKeyVariantKsn:[self parseHexStr2Byte:ksn] ipek:ipek];
}
//等待核对
+ (NSData *)GetDataKeyVariantKsn:(NSData *) ksn ipek: (NSData *)ipek
{
    
    NSData * key = [self GetDUKPTKeyKsn:ksn ipek:ipek];
    
   // NSLog(@"key = %@", key);
    
    NSInteger keyLen = [key length];
    Byte *keyC = (Byte *)malloc(keyLen);
    bzero(keyC, keyLen);
    
    [key getBytes:keyC length:keyLen];
    
    //key = GetDUKPTKey(ksn, ipek);
    keyC[5] ^= 0xFF;
    keyC[13] ^= 0xFF;
    
    NSData *keyDat = [NSData dataWithBytes:keyC length:keyLen];
    
    free(keyC);
    
    return keyDat;
}
//等待核对
+ (NSData *)GetPinKeyVariantKsn:(NSData *) ksn ipek: (NSData *)ipek
{
    NSData * key = [self GetDUKPTKeyKsn:ksn ipek:ipek];
    NSInteger keyLen = [key length];
    Byte *keyC = (Byte *)malloc(keyLen);
    bzero(keyC, keyLen);
    [key getBytes:keyC length:keyLen];
    
    //key = GetDUKPTKey(ksn, ipek);
    keyC[7] ^= 0xFF;
    keyC[15] ^= 0xFF;
    
    NSData *keyDat = [NSData dataWithBytes:keyC length:keyLen];
    free(keyC);
    return keyDat;
}

//等待核对
+ (NSData *)GetMacKeyVariantKsn:(NSData *) ksn ipek: (NSData *)ipek
{
    NSData * key = [self GetDUKPTKeyKsn:ksn ipek:ipek];
    NSInteger keyLen = [key length];
    Byte *keyC = (Byte *)malloc(keyLen);
    bzero(keyC, keyLen);
    [key getBytes:keyC length:keyLen];
    
    //key = GetDUKPTKey(ksn, ipek);
    keyC[6] ^= 0xFF;
    keyC[14] ^= 0xFF;
    
    NSData *keyDat = [NSData dataWithBytes:keyC length:keyLen];
    free(keyC);
    return keyDat;
}

//等待核对
+ (NSData *) GetDataKeyKsn:(NSData *) ksn ipek: (NSData *)ipek
{
    NSData *temp1 = [self GetDataKeyVariantKsn:ksn ipek:ipek];
    NSData *temp2 = [NSData dataWithData:temp1];
    
   // Byte *temp1C = (Byte *)[temp1 bytes];
   // Byte *temp2C = (Byte *)[temp2 bytes];
    
    //Byte *key =(Byte *)malloc(8);;
    //TDes_Encrypt(temp1C, key, temp2C);
    
    //Byte *key = [DUKPT_2009_CBC TriDesEncryptionKey:temp2C dec:temp1C];
   // Byte key[16] = {0};
    NSData *encReult2 = [DUKPT_2009_CBC DESOperation:kCCEncrypt algorithm:kCCAlgorithm3DES keySize:kCCKeySize3DES data:temp1 key:temp2];
    //[encReult2 getBytes:key length:16];
    
    ////byte[] key = TriDesEncryption(temp2,temp1);
    
    //NSData *keyDat = [NSData dataWithBytes:key length:16];
    return encReult2;
}

// 3DES加解密 kCCKeySizeDES
+ (NSData*)DESOperation:(CCOperation)operation algorithm:(CCAlgorithm)algorithm keySize:(size_t)keySize data:(NSData*)data key:(NSData*)key
{
//    NSLog(@"operation = %d", operation);
//    NSLog(@"key = %@", key);
//    NSLog(@"data = %@", data);
    
    //NSLog(@"algorithm = %d", algorithm);
    
    NSMutableData* alterKey = [NSMutableData dataWithData:key];
    [alterKey appendData:[key subdataWithRange:NSMakeRange(0, 8)]];
    
    size_t movedBytes = 0;
    const void* plainText = [data bytes];
    size_t plainTextBufferSize = [data length];
    
    size_t bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    
    uint8_t *bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *ptrKey = [alterKey bytes];
    
    CCCryptorStatus ccStatus = CCCrypt(operation, algorithm, kCCOptionECBMode, (const void *)ptrKey, keySize, NULL, (const void *)plainText, plainTextBufferSize, (void *)bufferPtr, bufferPtrSize, &movedBytes);
    
    if (ccStatus == kCCParamError) NSLog(@"PARAM ERROR");
    else if (ccStatus == kCCBufferTooSmall) NSLog(@"BUFFER TOO SMALL");
    else if (ccStatus == kCCMemoryFailure) NSLog(@"MEMORY FAILURE");
    else if (ccStatus == kCCAlignmentError); //NSLog(@"ALIGNMENT");
    else if (ccStatus == kCCDecodeError) NSLog(@"DECODE ERROR");
    else if (ccStatus == kCCUnimplemented) NSLog(@"UNIMPLEMENTED");
    
    
    NSData* result = [NSData dataWithBytes:bufferPtr length:movedBytes];
    //NSLog(@"result = %@ \n\n\n", result);
    return result;
    
}


// 3DES解密 CBC
+ (NSData*)DESOperationCBCdata:(NSData*)data key:(NSData*)key
{
    
    //NSLog(@"data = %@", data);
   // NSLog(@"key = %@", key);
    
    NSMutableData* alterKey = [NSMutableData dataWithData:key];
    [alterKey appendData:[key subdataWithRange:NSMakeRange(0, 8)]];
    
    size_t movedBytes = 0;
    const void* plainText = [data bytes];
    size_t plainTextBufferSize = [data length];
    
    size_t bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    
    uint8_t *bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *ptrKey = [alterKey bytes];
    const void *vinitVec = (const void *) [gIv UTF8String];
    CCCryptorStatus ccStatus = CCCrypt(kCCDecrypt, kCCAlgorithm3DES, kCCOptionECBMode, (const void *)ptrKey, kCCKeySize3DES, vinitVec, (const void *)plainText, plainTextBufferSize, (void *)bufferPtr, bufferPtrSize, &movedBytes);
    
    if (ccStatus == kCCParamError) NSLog(@"PARAM ERROR");
    else if (ccStatus == kCCBufferTooSmall) NSLog(@"BUFFER TOO SMALL");
    else if (ccStatus == kCCMemoryFailure) NSLog(@"MEMORY FAILURE");
    else if (ccStatus == kCCAlignmentError) NSLog(@"ALIGNMENT");
    else if (ccStatus == kCCDecodeError) NSLog(@"DECODE ERROR");
    else if (ccStatus == kCCUnimplemented) NSLog(@"UNIMPLEMENTED");
    
    //NSData* result1 = [NSData dataWithBytes:bufferPtr length:movedBytes];
    NSMutableData *result = [NSMutableData dataWithBytes:bufferPtr length:8];
    
    CCCryptorStatus ccStatus2 = CCCrypt(kCCDecrypt, kCCAlgorithm3DES, kCCOptionPKCS7Padding, (const void *)ptrKey, kCCKeySize3DES, vinitVec, (const void *)plainText, plainTextBufferSize, (void *)bufferPtr, bufferPtrSize, &movedBytes);
    
    if (ccStatus2 == kCCParamError) NSLog(@"PARAM ERROR");
    else if (ccStatus2 == kCCBufferTooSmall) NSLog(@"BUFFER TOO SMALL");
    else if (ccStatus2 == kCCMemoryFailure) NSLog(@"MEMORY FAILURE");
    else if (ccStatus2 == kCCAlignmentError) NSLog(@"ALIGNMENT");
    else if (ccStatus2 == kCCDecodeError) NSLog(@"DECODE ERROR");
    else if (ccStatus2 == kCCUnimplemented) NSLog(@"UNIMPLEMENTED");
    
    [result appendBytes:&bufferPtr[8] length:(movedBytes - 8)];
    
    //NSLog(@"result = %@ \n", result);
    return result;
}

// 十六进制字符串转字节数组 对
+(NSData *)parseHexStr2Byte: (NSString*)hexString
{
    if (hexString == nil) {
        return ([NSData new]);
    }
    const char * bytes = [hexString UTF8String];
    NSUInteger length = strlen(bytes);
    unsigned char * r = (unsigned char *) malloc(length / 2 + 1);
    unsigned char * index = r;
    
    while ((*bytes) && (*(bytes +1))) {
        char a=(*bytes);
        char b=(*(bytes +1));
        //*index = strToChar(a, b);
        char encoder[3] = {'\0','\0','\0'};
        encoder[0] = a;
        encoder[1] = b;
        *index = ((char) strtol(encoder,NULL,16));
        
        index++;
        bytes+=2;
    }
    *index = '\0';
    
    NSData * result = [NSData dataWithBytes: r length: length / 2];
    free(r);
    
    return (result);
}
//字节数组转十六进制字符串 对
+ (NSString*)parseByte2HexStr: (NSData *)data
{
    
    if (data == nil) {
        return ([NSString new]);
    }
    NSUInteger numBytes = [data length];
    const unsigned char* bytes = [data bytes];
    char *strbuf = (char *)malloc(numBytes * 2 + 1);
    char *hex = strbuf;
    NSString *hexBytes = nil;
    
    for (int i = 0; i<numBytes; ++i){
        const unsigned char c = *bytes++;
        *hex++ = HEXES[(c >> 4) & 0xF];
        *hex++ = HEXES[(c ) & 0xF];
    }
    *hex = 0;
    hexBytes = [NSString stringWithUTF8String:strbuf];
    free(strbuf);
    return (hexBytes);
}


//数据补位 对
+ (NSString *)dataFill:(NSString *)dataStr
{
    NSInteger len = dataStr.length;
    if (len % 16 != 0) {
        dataStr = [dataStr stringByAppendingString:@"80"];
        len = dataStr.length;
    }
    while (len % 16 != 0) {
        dataStr = [dataStr stringByAppendingString:@"0"];
        len ++;
        NSLog(@"%@", dataStr);
    }
    return dataStr;
}


//密码解密
+(NSString*)decryptionPinblock:(NSString*)ksn BDK:(NSString*)mBDK data:(NSString*)mData andCardNum:(NSString *)cardNum{
    
    NSData *byte_ksn = [self parseHexStr2Byte:ksn];
    NSData *byte_bdk = [self parseHexStr2Byte:mBDK];
    
    NSData *ipek = [self GenerateIPEKksn:byte_ksn bdk:byte_bdk];
    NSString *ipekStr = [self parseByte2HexStr:ipek];
    NSLog(@"ipekStr = %@", ipekStr);
    
    NSData *pinKey = [DUKPT_2009_CBC GetPinKeyVariantKsn:byte_ksn ipek:ipek];
    NSString *pinKeyStr = [DUKPT_2009_CBC parseByte2HexStr:pinKey];
    NSLog(@"pinKeyStr = %@", pinKeyStr);
    
    NSData *desData = [self DESOperation:kCCDecrypt algorithm:kCCAlgorithm3DES keySize:kCCKeySize3DES data:[DUKPT_2009_CBC parseHexStr2Byte:mData] key:pinKey];
//    NSData *desData = [DUKPT_2009_CBC DESOperation:kCCDecrypt algorithm:kCCAlgorithm3DES keySize:kCCKeySize3DES data:[DUKPT_2009_CBC parseHexStr2Byte:mData] key:[DUKPT_2009_CBC parseHexStr2Byte:pinKeyStr] andCcoption:kCCOptionPKCS7Padding | kCCOptionECBMode ];
    
    NSString *deResultStr = [self parseByte2HexStr:desData];
    
    NSString *handleCardNum = [cardNum substringWithRange:NSMakeRange(cardNum.length - 13, 12)];
    handleCardNum = [NSString stringWithFormat:@"0000%@",handleCardNum];
    
    deResultStr = [self pinxCreator:handleCardNum withPinv:deResultStr];
    
    return deResultStr;
}

//卡数据的解密10218072700005E0000B
+(NSString*)decryptionTrackDataCBC:(NSString*)ksn BDK:(NSString*)mBDK data:(NSString*)mData{
    
    NSData *byte_ksn = [self parseHexStr2Byte:ksn];
    NSData *byte_bdk = [self parseHexStr2Byte:mBDK];
    
    NSData *ipek = [self GenerateIPEKksn:byte_ksn bdk:byte_bdk];
    NSLog(@"ipek: %@",[self parseByte2HexStr:ipek]);
    
    NSData *dataKey = [DUKPT_2009_CBC GetDataKeyKsn:byte_ksn ipek:ipek];
//    NSString *dataKeyStr = [DUKPT_2009_CBC parseByte2HexStr:dataKey];
    NSLog(@"dataKey__: %@",[DUKPT_2009_CBC parseByte2HexStr:dataKey]);
    
   NSData *desData = [self DESOperationCBCdata:[DUKPT_2009_CBC parseHexStr2Byte:mData] key:dataKey];
//    NSData *desData = [DUKPT_2009_CBC DESOperation:kCCDecrypt algorithm:kCCAlgorithm3DES keySize:kCCKeySize3DES data:[DUKPT_2009_CBC parseHexStr2Byte:mData] key:[DUKPT_2009_CBC parseHexStr2Byte:dataKeyStr] andCcoption:kCCOptionPKCS7Padding];
    
    NSString *resa = [DUKPT_2009_CBC parseByte2HexStr:desData];
    
    return resa;
}

+ (NSString *)pinxCreator:(NSString *)pan withPinv:(NSString *)pinv{
    
    if (pan.length != pinv.length){
        return nil;
    }
    const char *panchar = [pan UTF8String];
    const char *pinvchar = [pinv UTF8String];
    
    NSString *temp = [[NSString alloc] init];
    
    for (int i = 0; i < pan.length; i++)
    {
        int panValue = [self charToint:panchar[i]];
        int pinvValue = [self charToint:pinvchar[i]];
        
        temp = [temp stringByAppendingString:[NSString stringWithFormat:@"%X",panValue^pinvValue]];
    }
    return temp;
}

+ (int)charToint:(char)tempChar{
    
    if (tempChar >= '0' && tempChar <='9'){
        return tempChar - '0';
    }
    else if (tempChar >= 'A' && tempChar <= 'F'){
        return tempChar - 'A' + 10;
    }
    return 0;
}


@end
