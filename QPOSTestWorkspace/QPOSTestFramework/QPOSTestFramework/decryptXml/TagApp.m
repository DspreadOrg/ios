//
//  EmvAppTag.m
//  01-DOM方式解析XML
//
//  Created by 方正伟 on 2018/8/1.
//  Copyright © 2018年 KY. All rights reserved.
//

#import "TagApp.h"

static NSString *Acquirer_Identifier = @"_9F01";
static NSString *Additional_Terminal_Capabilities = @"_9F40";
static NSString *Application_Identifier_AID_terminal = @"_9F06";
static NSString *Application_Selection_Indicator = @"_9F01";
static NSString *Application_Version_Number = @"_9F09";
static NSString *Contactless_Terminal_Additional_Capabilities = @"DF7A";
static NSString *Contactless_Terminal_Capabilities = @"DF79";
static NSString *Contactless_Terminal_Execute_Cvm_Limit = @"DF78";
static NSString *Currency_Exchange_Transaction_Reference = @"DF70";
static NSString *Currency_conversion_factor = @"_9F73";
static NSString *Default_DDOL = @"DF14";
static NSString *Default_Tdol = @"DF76";
static NSString *Electronic_cash_Terminal_Transaction_Limit = @"_9F7B";
static NSString *ICS = @"DF72";
static NSString *Identity_of_each_limit_exist = @"DF74";
static NSString *Interface_Device_IFD_Serial_Number = @"_9F1E";
static NSString * Maximum_Target_Percentage_to_be_used_for_Biased_Random_Selection = @"DF16";
static NSString *Merchant_Category_Code = @"_9F15";
static NSString *Merchant_Identifier = @"_9F16";
static NSString *Merchant_Name_and_Location = @"_9F4E";
static NSString *Point_of_Service_POS_EntryMode = @"_9F39";
static NSString *Script_length_Limit = @"DF71";
static NSString *TAC_Default = @"DF11";
static NSString *TAC_Denial = @"DF13";
static NSString *TAC_Online = @"DF12";
static NSString *Target_Percentage_to_be_Used_for_Random_Selection = @"DF17";
static NSString *Terminal_Capabilities = @"_9F33";
static NSString *Terminal_Country_Code = @"_9F1A";
static NSString *Terminal_Default_Transaction_Qualifiers = @"_9F66";
static NSString *Terminal_Floor_Limit = @"_9F1B";
static NSString *Terminal_Identification = @"_9F1C";
static NSString *Terminal_type = @"_9F35";
static NSString *Threshold_Value_BiasedRandom_Selection = @"DF15";
static NSString *Transaction_Currency_Code = @"_9F2A";
static NSString *Transaction_Currency_Exponent = @"_9F36";
static NSString *Transaction_Reference_Currency_Code = @"_9F3C";
static NSString *Transaction_Reference_Currency_Exponent = @"_9F3D";
static NSString *status = @"DF73";
static NSString *terminal_contactless_offline_floor_limit = @"DF19";
static NSString *terminal_contactless_transaction_limit = @"DF20";
static NSString *terminal_execute_cvm_limit = @"DF21";
static NSString *terminal_status_check = @"DF75";

@implementation TagApp

- (NSString *)description {
    
    return [NSString stringWithFormat:@"---%@----%@---", self.Acquirer_Identifier,self.Additional_Terminal_Capabilities];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (void)setValue:(id)value forKey:(NSString *)key{
    
    if ([key isEqualToString:Acquirer_Identifier]) {
        
        _Acquirer_Identifier = value;
        
    }else if ([key isEqualToString:Additional_Terminal_Capabilities]){
        
        _Additional_Terminal_Capabilities = value;
        
    }else if ([key isEqualToString:Application_Identifier_AID_terminal]){
        
        _Application_Identifier_AID_terminal = value;
        
    }else if ([key isEqualToString:Application_Selection_Indicator]){
        
        _Application_Selection_Indicator = value;
        
    }else if ([key isEqualToString:Application_Version_Number]){
        
        _Application_Version_Number = value;
    }else if ([key isEqualToString:Contactless_Terminal_Additional_Capabilities]){
        
        _Contactless_Terminal_Additional_Capabilities = value;
        
    }else if ([key isEqualToString:Contactless_Terminal_Capabilities]){
        
        _Contactless_Terminal_Capabilities = value;
        
    }else if ([key isEqualToString:Contactless_Terminal_Execute_Cvm_Limit]){
        
        _Contactless_Terminal_Execute_Cvm_Limit = value;
        
    }else if ([key isEqualToString:Currency_Exchange_Transaction_Reference]){
        
        _Currency_Exchange_Transaction_Reference = value;
        
    }else if ([key isEqualToString:Currency_conversion_factor]){
        
        _Currency_conversion_factor = @"";
        
    }else if ([key isEqualToString:Default_DDOL]){
        
        _Default_DDOL = value;
        
    }else if ([key isEqualToString:Default_Tdol]){
        
        _Default_Tdol = value;
        
    }else if ([key isEqualToString:Electronic_cash_Terminal_Transaction_Limit]){
        
        _Electronic_cash_Terminal_Transaction_Limit = value;
        
    }else if ([key isEqualToString:ICS]){
        
        _ICS = value;
    }else if ([key isEqualToString:Identity_of_each_limit_exist]){
        
        _Identity_of_each_limit_exist = value;
        
    }else if ([key isEqualToString:Interface_Device_IFD_Serial_Number]){
        
        _Interface_Device_IFD_Serial_Number = value;
        
    }else if ([key isEqualToString:Maximum_Target_Percentage_to_be_used_for_Biased_Random_Selection]){
        
        _Maximum_Target_Percentage_to_be_used_for_Biased_Random_Selection = value;
        
    }else if ([key isEqualToString:Merchant_Category_Code]){
        
        _Merchant_Category_Code = value;
        
    }else if ([key isEqualToString:Merchant_Identifier]){
        
        _Merchant_Identifier = value;
        
    }else if ([key isEqualToString:Merchant_Name_and_Location]){
        
        _Merchant_Name_and_Location = value;
        
    }else if ([key isEqualToString:Point_of_Service_POS_EntryMode]){
        
        _Point_of_Service_POS_EntryMode = value;
        
    }else if ([key isEqualToString:Script_length_Limit]){
        
        _Script_length_Limit= value;
    }else if ([key isEqualToString:TAC_Default]){
        /*
         "TAC_Default" = DF11;
         "TAC_Denial" = DF13;
         "TAC_Online" = DF12;
         "Target_Percentage_to_be_Used_for_Random_Selection" = DF17;
         "Terminal_Capabilities" = AF33;
         "Terminal_Country_Code" = AF1A;
         "Terminal_Default_Transaction_Qualifiers" = AF66;
         "Terminal_Floor_Limit" = AF1B;
         "Terminal_Identification" = AF1C;
         "Terminal_type" = AF35;
         "Threshold_Value_BiasedRandom_Selection" = DF15;
         "Transaction_Currency_Code" = AF2A;
         "Transaction_Currency_Exponent" = AF36;
         "Transaction_Reference_Currency_Code" = AF3C;
         "Transaction_Reference_Currency_Exponent" = AF3D;
         status = DF73;
         "terminal_contactless_offline_floor_limit" = DF19;
         "terminal_contactless_transaction_limit" = DF20;
         "terminal_execute_cvm_limit" = DF21;
         "terminal_status_check" = DF75;
         */
        _TAC_Default = value;
    }else if ([key isEqualToString:TAC_Denial]){
        
        _TAC_Denial = value;
    }else if ([key isEqualToString:TAC_Online]){
        
        _TAC_Online = value;
        
    }else if ([key isEqualToString:Target_Percentage_to_be_Used_for_Random_Selection]){
        
        _Target_Percentage_to_be_Used_for_Random_Selection = value;
    }else if ([key isEqualToString:Terminal_Capabilities]){
        
        _Terminal_Capabilities = value;
        
    }else if ([key isEqualToString:Terminal_Country_Code]){
        
        _Terminal_Country_Code = value;
    }else if ([key isEqualToString:Terminal_Default_Transaction_Qualifiers]){
        
        _Terminal_Default_Transaction_Qualifiers = value;
        
    }else if ([key isEqualToString:Terminal_Floor_Limit]){
        
        _Terminal_Floor_Limit = value;
    }else if ([key isEqualToString:Terminal_Identification]){
        /*
         "Terminal_Country_Code" = AF1A;
         "Terminal_Default_Transaction_Qualifiers" = AF66;
         "Terminal_Floor_Limit" = AF1B;
         "Terminal_Identification" = AF1C;
         "Terminal_type" = AF35;
         "Threshold_Value_BiasedRandom_Selection" = DF15;
         "Transaction_Currency_Code" = AF2A;
         "Transaction_Currency_Exponent" = AF36;
         "Transaction_Reference_Currency_Code" = AF3C;
         "Transaction_Reference_Currency_Exponent" = AF3D;
         status = DF73;
         "terminal_contactless_offline_floor_limit" = DF19;
         "terminal_contactless_transaction_limit" = DF20;
         "terminal_execute_cvm_limit" = DF21;
         "terminal_status_check" = DF75;
         */
        _Terminal_Identification = value;
    }else if ([key isEqualToString:Terminal_type]){
        
        _Terminal_type = value;
    }else if ([key isEqualToString:Threshold_Value_BiasedRandom_Selection]){
        
        _Threshold_Value_BiasedRandom_Selection = value;
        
    }else if ([key isEqualToString:Transaction_Currency_Code]){
        
        _Transaction_Currency_Code = value;
        
    }else if ([key isEqualToString:Transaction_Currency_Exponent]){
        
        _Transaction_Currency_Exponent = value;
    }else if ([key isEqualToString:Transaction_Reference_Currency_Code]){
        
        _Transaction_Reference_Currency_Code = value;
    }else if ([key isEqualToString:Transaction_Reference_Currency_Exponent]){
        
        _Transaction_Reference_Currency_Exponent = value;
        
    }else if ([key isEqualToString:status]){
        
        _status = value;
    }else if ([key isEqualToString:terminal_contactless_offline_floor_limit]){
        /*
         terminal_contactless_offline_floor_limit" = DF19;
         "terminal_contactless_transaction_limit" = DF20;
         "terminal_execute_cvm_limit" = DF21;
         "terminal_status_check" = DF75;
         */
        _terminal_contactless_offline_floor_limit = value;
    }else if ([key isEqualToString:terminal_contactless_transaction_limit]){
        
        _terminal_contactless_transaction_limit = value;
        
    }else if ([key isEqualToString:terminal_execute_cvm_limit]){
        
        _terminal_execute_cvm_limit = value;
    }else if ([key isEqualToString:terminal_status_check]){
        
        _terminal_status_check = value;
    }
}
@end
