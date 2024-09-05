//
//  RSA.m
//  qpos-ios-demo
//
//  Created by 方正伟 on 9/3/24.
//  Copyright © 2024 Robin. All rights reserved.
//

#import "RSA.h"
#import "QPOSUtil.h"
@implementation RSA
#pragma mark ---生成密钥对
+ (BOOL)generateSecKeyPairWithKeySize:(NSUInteger)keySize publicKeyRef:(SecKeyRef *)publicKeyRef privateKeyRef:(SecKeyRef *)privateKeyRef{
    OSStatus sanityCheck = noErr;
    if (keySize == 512 || keySize == 1024 || keySize == 2048) {
        NSData *publicTag = [@"com.your.company.publickey" dataUsingEncoding:NSUTF8StringEncoding];
        NSData *privateTag = [@"com.your.company.privateTag" dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableDictionary * privateKeyAttr = [[NSMutableDictionary alloc] init];
        NSMutableDictionary * publicKeyAttr = [[NSMutableDictionary alloc] init];
        NSMutableDictionary * keyPairAttr = [[NSMutableDictionary alloc] init];
        
        // Set top level dictionary for the keypair.
        [keyPairAttr setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
        [keyPairAttr setObject:[NSNumber numberWithUnsignedInteger:keySize] forKey:(id)kSecAttrKeySizeInBits];
        
        // Set the private key dictionary.
        [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecAttrIsPermanent];
        [privateKeyAttr setObject:privateTag forKey:(id)kSecAttrApplicationTag];
        // See SecKey.h to set other flag values.
        
        // Set the public key dictionary.
        [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecAttrIsPermanent];
        [publicKeyAttr setObject:publicTag forKey:(id)kSecAttrApplicationTag];
        // See SecKey.h to set other flag values.
        
        // Set attributes to top level dictionary.
        [keyPairAttr setObject:privateKeyAttr forKey:(id)kSecPrivateKeyAttrs];
        [keyPairAttr setObject:publicKeyAttr forKey:(id)kSecPublicKeyAttrs];
        
        // SecKeyGeneratePair returns the SecKeyRefs just for educational purposes.
        sanityCheck = SecKeyGeneratePair((CFDictionaryRef)keyPairAttr, publicKeyRef, privateKeyRef);
        if ( sanityCheck == noErr && publicKeyRef != NULL && privateKeyRef != NULL) {
            return YES;
        }
    }
    return NO;
}

#pragma mark ---密钥类型转换
static NSString * const kTransfromIdenIdentifierPublic = @"kTransfromIdenIdentifierPublic";
static NSString * const kTransfromIdenIdentifierPrivate = @"kTransfromIdenIdentifierPrivate";
+ (NSData *)publicKeyBitsFromSecKey:(SecKeyRef)givenKey {
    return (NSData*)CFBridgingRelease(SecKeyCopyExternalRepresentation(givenKey, NULL));
}

+ (SecKeyRef)publicSecKeyFromKeyBits:(NSData *)givenData {
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    options[(__bridge id)kSecAttrKeyType] = (__bridge id) kSecAttrKeyTypeRSA;
    options[(__bridge id)kSecAttrKeyClass] = (__bridge id) kSecAttrKeyClassPublic;

    NSError *error = nil;
    CFErrorRef ee = (__bridge CFErrorRef)error;
    
    SecKeyRef ret = SecKeyCreateWithData((__bridge CFDataRef)givenData, (__bridge CFDictionaryRef)options, &ee);
    if (error) {
        return nil;
    }
    return ret;
}

+ (NSData *)privateKeyBitsFromSecKey:(SecKeyRef)givenKey {
    return (NSData*)CFBridgingRelease(SecKeyCopyExternalRepresentation(givenKey, NULL));
}

+ (SecKeyRef)privateSecKeyFromKeyBits:(NSData *)givenData {
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    options[(__bridge id)kSecAttrKeyType] = (__bridge id) kSecAttrKeyTypeRSA;
    options[(__bridge id)kSecAttrKeyClass] = (__bridge id) kSecAttrKeyClassPrivate;
    
    NSError *error = nil;
    CFErrorRef ee = (__bridge CFErrorRef)error;
    
    SecKeyRef ret = SecKeyCreateWithData((__bridge CFDataRef)givenData, (__bridge CFDictionaryRef)options, &ee);
    if (error) {
        return nil;
    }
    return ret;
}

#pragma mark ---加解密
+ (NSData *)encryptWithKey:(SecKeyRef)key plainData:(NSData *)plainData padding:(SecPadding)padding {
    if (!key) {
        return nil;
    }
    if (!plainData) {
        return nil;
    }
//    size_t paddingSize = 1; // 防止明文大于模数
//    if (padding == kSecPaddingNone) {
//        paddingSize = 11;
//    }
    size_t keySize = SecKeyGetBlockSize(key) * sizeof(uint8_t);
    double totalLength = [plainData length];
    size_t blockSize = 117; //分块加密,每块117字节
    int blockCount = ceil(totalLength / blockSize);
    NSMutableData *encryptData = [NSMutableData data];
    for (int i = 0; i < blockCount; i++) {
        NSUInteger loc = i * blockSize;
        int dataSegmentRealSize = MIN(blockSize, totalLength - loc);
        NSData *dataSegment = [plainData subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
//        NSLog(@"dataSegment: %@",[QPOSUtil byteArray2Hex:dataSegment]);
        unsigned char *cipherBuffer = malloc(keySize);
        memset(cipherBuffer, 0, keySize);
        OSStatus status = noErr;
        size_t cipherBufferSize = keySize;
        status = SecKeyEncrypt(key,
                               padding,
                               [dataSegment bytes],
                               dataSegmentRealSize,
                               cipherBuffer,
                               &cipherBufferSize
                               );
        
        if(status == noErr){
            NSData *resultData = [[NSData alloc] initWithBytes:cipherBuffer length:cipherBufferSize];
            [encryptData appendData:resultData];
            free(cipherBuffer);
        } else {
            free(cipherBuffer);
            return nil;
        }
    }
    return encryptData;
}
+ (NSData *)decryptWithKey:(SecKeyRef)key cipherData:(NSData *)cipherData padding:(SecPadding)padding {
    if (!key) {
        return nil;
    }
    if (!cipherData) {
        return nil;
    }
    
    size_t keySize = SecKeyGetBlockSize(key) * sizeof(uint8_t);
    double totalLength = [cipherData length];
    size_t blockSize = keySize;
    int blockCount = ceil(totalLength / blockSize);
    NSMutableData *decrypeData = [NSMutableData data];
    for (int i = 0; i < blockCount; i++) {
        NSUInteger loc = i * blockSize;
        long dataSegmentRealSize = MIN(blockSize, totalLength - loc);
        NSData *dataSegment = [cipherData subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
        unsigned char *plainBuffer = malloc(keySize);
        memset(plainBuffer, 0, keySize);
        OSStatus status = noErr;
        size_t plainBufferSize = keySize ;
        status = SecKeyDecrypt(key,
                               padding,
                               [dataSegment bytes],
                               dataSegmentRealSize,
                               plainBuffer,
                               &plainBufferSize
                               );
        if(status == noErr){
            NSData *data = [[NSData alloc] initWithBytes:plainBuffer length:plainBufferSize];
            [decrypeData appendData:data];
            free(plainBuffer);
        } else {
            free(plainBuffer);
            return nil;
        }
    }
    
    return decrypeData;
    
}

+ (NSData *)encryptWithPrivateKey:(SecKeyRef)key plainData:(NSData *)plainData  {
    if (!key) {
        return nil;
    }
    if (!plainData) {
        return nil;
    }
    
    size_t paddingSize = 1; // 分段长度 -1 ，兼容有中文的情况。
    size_t keySize = SecKeyGetBlockSize(key) * sizeof(uint8_t);
    double totalLength = [plainData length];
    size_t blockSize = keySize - paddingSize;
    int blockCount = ceil(totalLength / blockSize);
    NSMutableData *encryptData = [NSMutableData data];
    for (int i = 0; i < blockCount; i++) {
        NSUInteger loc = i * blockSize;
        int dataSegmentRealSize = MIN(blockSize, totalLength - loc);
        NSData *dataSegment = [plainData subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
        unsigned char *cipherBuffer = malloc(keySize);
        memset(cipherBuffer, 0, keySize);
        
        OSStatus status = noErr;
        size_t cipherBufferSize = keySize;
        status = SecKeyDecrypt(key,
                               kSecPaddingNone,
                               [dataSegment bytes],
                               dataSegmentRealSize,
                               cipherBuffer,
                               &cipherBufferSize
                               );
        
        if(status == noErr){
            // 如果解密出来的数据小于 keySize 需要 在前面拼接 00
            if (cipherBufferSize != keySize) {
                NSInteger paddingLength = keySize - cipherBufferSize;
                const char fixByte = 0;
                NSMutableData * fixedData = [NSMutableData dataWithBytes:&fixByte length:paddingLength];
                [fixedData appendBytes:cipherBuffer length:cipherBufferSize];
                [encryptData appendData:fixedData];
            } else {
                NSData *resultData = [[NSData alloc] initWithBytes:cipherBuffer length:keySize];
                [encryptData appendData:resultData];
            }
        } else {
            free(cipherBuffer);
            return nil;
        }
        free(cipherBuffer);
    }
    return encryptData;
}

+ (NSData *)decryptWithPublicKey:(SecKeyRef)publicKeyRef cipherData:(NSData *)cipherData {
    if (!publicKeyRef) {
        return nil;
    }
    if (!cipherData) {
        return nil;
    }
    
    size_t keySize = SecKeyGetBlockSize(publicKeyRef) * sizeof(uint8_t);
    double totalLength = [cipherData length];
    size_t blockSize = keySize;
    int blockCount = ceil(totalLength / blockSize);
    NSMutableData *plainData = [NSMutableData data];
    for (int i = 0; i < blockCount; i++) {
        NSUInteger loc = i * blockSize;
        long dataSegmentRealSize = MIN(blockSize, totalLength - loc);
        NSData *dataSegment = [cipherData subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
        unsigned char *plainBuffer = malloc(keySize);
        memset(plainBuffer, 0, keySize);
        OSStatus status = noErr;
        size_t plainBufferSize = keySize;
        status = SecKeyDecrypt(publicKeyRef,
                               kSecPaddingNone, // 解密的时候一定要用 无填充模式，拿到所有的数据自行解析
                               [dataSegment bytes],
                               dataSegmentRealSize,
                               plainBuffer,
                               &plainBufferSize
                               );
        
        NSAssert(status == noErr, @"Decrypt error");
        if(status != noErr){
            free(plainBuffer);
            return nil;
        }
        
        NSData *data = [[NSData alloc] initWithBytes:plainBuffer length:plainBufferSize];
        
        NSData *startData = [data subdataWithRange:NSMakeRange(0, 1)];
        // 开头应该是 0001 但是原生解出来之后把开头的 00 忽略了
        if ([[startData description] isEqualToString:@"<01>"]) {
            Byte flag[] = {0x00};
            NSRange startRange = [data rangeOfData:[NSData dataWithBytes:flag length:1] options:NSDataSearchBackwards range:NSMakeRange(0, data.length)];
            NSUInteger s = startRange.location + startRange.length;
            if (startRange.location != NSNotFound && s < data.length) {
                data = [data subdataWithRange:NSMakeRange(s, data.length - s)];
            }
        }
        
        [plainData appendData:data];
        free(plainBuffer);
    }
    
    return plainData;
}

#pragma mark - 公钥与模数和指数转换
//公钥指数
+ (NSData *)getPublicKeyExp:(NSData *)pk {

    if (pk == NULL) return NULL;
    int iterator = 0;
    iterator++; // TYPE - bit stream - mod + exp
    [self derEncodingGetSizeFrom:pk at:&iterator]; // Total size
    
    iterator++; // TYPE - bit stream mod
    int mod_size = [self derEncodingGetSizeFrom:pk at:&iterator];
    iterator += mod_size;
    
    iterator++; // TYPE - bit stream exp
    int exp_size = [self derEncodingGetSizeFrom:pk at:&iterator];
    
    return [pk subdataWithRange:NSMakeRange(iterator, exp_size)];
}
//模数
+ (NSData *)getPublicKeyMod:(NSData *)pk {
    if (pk == NULL) return NULL;
    int iterator = 0;
    iterator++; // TYPE - bit stream - mod + exp
    [self derEncodingGetSizeFrom:pk at:&iterator]; // Total size
    
    iterator++; // TYPE - bit stream mod
    int mod_size = [self derEncodingGetSizeFrom:pk at:&iterator];
    
    return [pk subdataWithRange:NSMakeRange(iterator, mod_size)];
}

+ (int)derEncodingGetSizeFrom:(NSData*)buf at:(int*)iterator {
    const uint8_t* data = [buf bytes];
    int itr = *iterator;
    int num_bytes = 1;
    int ret = 0;
    
    if (data[itr] > 0x80) {
        num_bytes = data[itr] - 0x80;
        itr++;
    }
    
    for (int i = 0 ; i < num_bytes; i++) ret = (ret * 0x100) + data[itr + i];
    
    *iterator = itr + num_bytes;
    return ret;
}

+ (SecKeyRef)publicKeyDataWithMod:(NSData *)modBits exp:(NSData *)expBits {
    /*
        整个数据分为8个部分
        0x30 包长 { 0x02 包长 { modBits} 0x02 包长 { expBits } }
     */
    //创建证书存储空间，其中第二第四部分包长按照 ** 1byte ** 处理，如果不够在后面在添加
    NSMutableData *fullKey = [[NSMutableData alloc] initWithLength:6+[modBits length]+[expBits length]];
    unsigned char *fullKeyBytes = [fullKey mutableBytes];
    
    unsigned int bytep = 0; // 当前指针位置
    
    //第一部分：（1 byte）固定位0x30
    fullKeyBytes[bytep++] = 0x30;
    
    //第二部分：（1-3 byte）记录总包长
    NSUInteger ml = 4 + [modBits length]  + [expBits length];
    if (ml >= 256) {
        
        //当长度大于256时占用 3 byte
        fullKeyBytes[bytep++] = 0x82;
        [fullKey increaseLengthBy:2];
        
        //先设置高位数据
        fullKeyBytes[bytep++] = ml >> 8;
    }else if(ml >= 128) {
        
        //当长度大于128时占用 2 byte
        fullKeyBytes[bytep++] = 0x81 ;
        [fullKey increaseLengthBy:1];
    }
    unsigned int seqLenLoc = bytep; // 记录总长数据的位置，如果需要添加可直接取值
    fullKeyBytes[bytep++] = 4 + [modBits length] + [expBits length]; // 默认第二第四部分包长按照 ** 1byte ** 处理
    
    //第三部分 （1 byte）固定位0x02
    fullKeyBytes[bytep++] = 0x02;
    
    //第四部分：（1-3 byte）记录包长
    ml = [modBits length];
    if (ml >= 256) {
        
        //当长度大于256时占用 3 byte
        fullKeyBytes[bytep++] = 0x82;
        [fullKey increaseLengthBy:2];
        
        //先设置高位数据
        fullKeyBytes[bytep++] = ml >> 8;
        
        //第二部分包长+2
        fullKeyBytes[seqLenLoc] += 2;
    }else if(ml >= 128){
        //当长度大于256时占用 2 byte
        fullKeyBytes[bytep++] = 0x81 ;
        [fullKey increaseLengthBy:1];
        
        //第二部分包长＋1
        fullKeyBytes[seqLenLoc]++;
    }
    // 这里如果 [modBits length] > 255 (ff),就会数据溢出，高位会被截断。所以上面 ml >> 8 先对高位进行了复制
    fullKeyBytes[bytep++] = [modBits length];
    
    
    //第五部分
    [modBits getBytes:&fullKeyBytes[bytep] length:[modBits length]];
    bytep += [modBits length];
    
    //第六部分
    fullKeyBytes[bytep++] = 0x02;
    
    //第七部分
    fullKeyBytes[bytep++] = [expBits length];
    
    //第八部分
    [expBits getBytes:&fullKeyBytes[bytep++] length:[expBits length]];
    
    
    return [self publicSecKeyFromKeyBits:fullKey];
}

+ (NSString *)encryptOperation:(CCOperation)operation value:(NSString *)data key:(NSString *)key{
    NSUInteger blockSize = kCCBlockSizeAES128;
    NSUInteger dataLength = data.length;
    size_t bufferSize = dataLength + blockSize;
    void * buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    NSData *dataKey = [QPOSUtil HexStringToByteArray:key];
    NSData *dataIn = [QPOSUtil HexStringToByteArray:data];
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          0x0000 | kCCOptionECBMode,
                                          dataKey.bytes,
                                          dataKey.length,
                                          0,
                                          dataIn.bytes,
                                          dataIn.length,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        NSData * result = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        if (result != nil) {
            return [QPOSUtil byteArray2Hex:result];
        }
        free(buffer);
    } else {
        if (buffer) {
            free(buffer);
            buffer = NULL;
        }
    }
    return nil;
}

//解密
+(NSString *)AES128Decrypt:(NSString *)encryptText key:(NSString *)key
{
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
      
    //NSData *data = [GTMBase64 decodeData:[encryptText dataUsingEncoding:NSUTF8StringEncoding]];
      
    NSData *data=[QPOSUtil HexStringToByteArray:encryptText];
      
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
      
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          NULL,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        //NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
//        return [[[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding] autorelease];
    }
    free(buffer);
    return nil;
}

#pragma mark - Base64

+ (NSString *)base64EncodeData:(NSData *)data{
    data = [data base64EncodedDataWithOptions:0];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return ret;
}

+ (NSData *)base64DecodeString:(NSString *)string{
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return data;
}

+ (SecKeyRef)addPrivateKey1:(NSString *)key{
    NSRange spos = [key rangeOfString:@"-----BEGIN PRIVATE KEY-----"];
    NSRange epos = [key rangeOfString:@"-----END PRIVATE KEY-----"];
    if(spos.location != NSNotFound && epos.location != NSNotFound){
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        key = [key substringWithRange:range];
    }

    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" "  withString:@""];
    NSData *data = base64_decode(key);
    data = [self stripPrivateKeyHeader:data];
    if(!data){
      return nil;
    }

    NSString *tag = @"RSAUtil_PrivKey";

    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];

    NSMutableDictionary *privateKey = [[NSMutableDictionary alloc] init];

    [privateKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];

    [privateKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];

    [privateKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];

    SecItemDelete((__bridge CFDictionaryRef)privateKey);

    [privateKey setObject:data forKey:(__bridge id)kSecValueData];

    [privateKey setObject:(__bridge id) kSecAttrKeyClassPrivate forKey:(__bridge id)

    kSecAttrKeyClass];

    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)

    kSecReturnPersistentRef];

    CFTypeRef persistKey = nil;

    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)privateKey, &persistKey);

    if (persistKey != nil){
       CFRelease(persistKey);
    }

    if ((status != noErr) && (status != errSecDuplicateItem)) {
       return nil;
    }

    [privateKey removeObjectForKey:(__bridge id)kSecValueData];
    [privateKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [privateKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)privateKey, (CFTypeRef *)&keyRef);
    if(status != noErr){
      return nil;
    }
      return keyRef;
    }
    static NSData *base64_decode(NSString *str){
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return data;
}

+ (NSData *)stripPrivateKeyHeader:(NSData *)d_key{

// Skip ASN.1 private key header

if (d_key == nil) return(nil);

unsigned long len = [d_key length];

if (!len) return(nil);

unsigned char *c_key = (unsigned char *)[d_key bytes];

unsigned int  idx    = 22; //magic byte at offset 22

if (0x04 != c_key[idx++]) return nil;

//calculate length of the key

unsigned int c_len = c_key[idx++];

int det = c_len & 0x80;

if (!det) {

c_len = c_len & 0x7f;

} else {

int byteCount = c_len & 0x7f;

if (byteCount + idx > len) {

//rsa length field longer than buffer

return nil;

}

unsigned int accum = 0;

unsigned char *ptr = &c_key[idx];

idx += byteCount;

while (byteCount) {

accum = (accum << 8) + *ptr;

ptr++;

byteCount--;

}

c_len = accum;

}

// Now make a new NSData from this buffer

return [d_key subdataWithRange:NSMakeRange(idx, c_len)];

}

// 3DES加解密 kCCKeySizeDES
+ (NSData*)DESOperation:(CCOperation)operation algorithm:(CCAlgorithm)algorithm keySize:(size_t)keySize data:(NSData*)data key:(NSData*)key{
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
    else if (ccStatus == kCCAlignmentError) NSLog(@"ALIGNMENT");
    else if (ccStatus == kCCDecodeError) NSLog(@"DECODE ERROR");
    else if (ccStatus == kCCUnimplemented) NSLog(@"UNIMPLEMENTED");
    
    
    NSData* result = [NSData dataWithBytes:bufferPtr length:movedBytes];
    free(bufferPtr);
    return result;
    
}
@end
