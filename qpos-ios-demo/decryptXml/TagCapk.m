//
//  TagCapk.m
//  qpos-ios-demo
//
//  Created by 方正伟 on 2018/8/8.
//  Copyright © 2018年 Robin. All rights reserved.
//

#import "TagCapk.h"

@implementation TagCapk

- (NSString *)description {

    return [NSString stringWithFormat:@"---%@----%@---%@----%@", self.Rid,self.Public_Key_CheckValue,self.Public_Key_Module,self.Public_Key_Index];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (void)setValue:(id)value forKey:(NSString *)key{
    
    if ([key isEqualToString:RID]) {
        
        _Rid = value;
        
    }else if ([key isEqualToString:Public_Key_Index]){
        
        _Public_Key_Index= value;
        
    }else if ([key isEqualToString:Public_Key_Module]){
        
        _Public_Key_Module = value;
        
    }else if ([key isEqualToString:Public_Key_CheckValue]){
        
        _Public_Key_CheckValue = value;
        
    }else if ([key isEqualToString:Pk_exponent]){
        
        _Pk_exponent = value;
    }else if ([key isEqualToString:Hash_algorithm_identification]){
        
        _Hash_algorithm_identification = value;
        
    }else if ([key isEqualToString:Pk_algorithm_identification]){
        
        _Pk_algorithm_identification = value;
    }
}
@end
