//
//  EmvAppTag.h
//  01-DOM方式解析XML
//
//  Created by 方正伟 on 2018/8/1.
//  Copyright © 2018年 KY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagApp : NSObject
/*
 "Acquirer_Identifier" = 9F01;
 "Additional_Terminal_Capabilities" = 9F40;
 "Application_Identifier_AID_terminal" = 9F06;
 "Application_Selection_Indicator" = DF01;
 "Application_Version_Number" = 9F09;
 "Contactless_Terminal_Additional_Capabilities" = DF7A;
 "Contactless_Terminal_Capabilities" = DF79;
 "Contactless_Terminal_Execute_Cvm_Limit" = DF78;
 "Currency_Exchange_Transaction_Reference" = DF70;
 "Currency_conversion_factor" = 9F73;
 "Default_DDOL" = DF14;
 "Default_Tdol" = DF76;
 "Electronic_cash_Terminal_Transaction_Limit" = 9F7B;
 ICS = DF72;
 "Identity_of_each_limit_exist" = DF74;
 "Interface_Device_IFD_Serial_Number" = 9F1E;
 "Maximum_Target_Percentage_to_be_used_for_Biased_Random_Selection" = DF16;
 "Merchant_Category_Code" = 9F15;
 "Merchant_Identifier" = 9F16;
 "Merchant_Name_and_Location" = 9F4E;
 "Point_of_Service_POS_EntryMode" = 9F39;
 "Script_length_Limit" = DF71;
 "TAC_Default" = DF11;
 "TAC_Denial" = DF13;
 "TAC_Online" = DF12;
 "Target_Percentage_to_be_Used_for_Random_Selection" = DF17;
 "Terminal_Capabilities" = 9F33;
 "Terminal_Country_Code" = 9F1A;
 "Terminal_Default_Transaction_Qualifiers" = 9F66;
 "Terminal_Floor_Limit" = 9F1B;
 "Terminal_Identification" = 9F1C;
 "Terminal_type" = 9F35;
 "Threshold_Value_BiasedRandom_Selection" = DF15;
 "Transaction_Currency_Code" = 5F2A;
 "Transaction_Currency_Exponent" = 5F36;
 "Transaction_Reference_Currency_Code" = 9F3C;
 "Transaction_Reference_Currency_Exponent" = 9F3D;
 status = DF73;
 "terminal_contactless_offline_floor_limit" = DF19;
 "terminal_contactless_transaction_limit" = DF20;
 "terminal_execute_cvm_limit" = DF21;
 "terminal_status_check" = DF75;
 
 */
@property (nonatomic, copy) NSString *Acquirer_Identifier;//9F01

@property (nonatomic, copy) NSString *Additional_Terminal_Capabilities;//9F40
@property (nonatomic, copy) NSString *Application_Identifier_AID_terminal;//9F06

@property (nonatomic, copy) NSString *Application_Selection_Indicator;//9F01

@property (nonatomic, copy) NSString *Application_Version_Number;//9F09

@property (nonatomic, copy) NSString *Contactless_Terminal_Additional_Capabilities;//DF7A

@property (nonatomic, copy) NSString *Contactless_Terminal_Capabilities;//DF79

@property (nonatomic, copy) NSString *Contactless_Terminal_Execute_Cvm_Limit;
//"Contactless_Terminal_Execute_Cvm_Limit" = DF78;
@property (nonatomic, copy) NSString *Currency_Exchange_Transaction_Reference;
//"Currency_Exchange_Transaction_Reference" = DF70;
@property (nonatomic, copy) NSString *Currency_conversion_factor;
// "Currency_conversion_factor" = 9F73;
@property (nonatomic, copy) NSString *Default_DDOL;
// "Default_DDOL" = DF14;
@property (nonatomic, copy) NSString *Default_Tdol;
// "Default_Tdol" = DF76;
@property (nonatomic, copy) NSString *Electronic_cash_Terminal_Transaction_Limit;
//"Electronic_cash_Terminal_Transaction_Limit" = 9F7B;
@property (nonatomic, copy) NSString *ICS;
//ICS = DF72;
@property (nonatomic, copy) NSString *Identity_of_each_limit_exist;
// "Identity_of_each_limit_exist" = DF74;
@property (nonatomic, copy) NSString *Interface_Device_IFD_Serial_Number;
// "Interface_Device_IFD_Serial_Number" = 9F1E;
@property (nonatomic, copy) NSString *Maximum_Target_Percentage_to_be_used_for_Biased_Random_Selection;
//"Maximum_Target_Percentage_to_be_used_for_Biased_Random_Selection" = DF16;
@property (nonatomic, copy) NSString *Merchant_Category_Code;
//"Merchant_Category_Code" = 9F15;
@property (nonatomic, copy) NSString *Merchant_Identifier;
//"Merchant_Identifier" = 9F16;
@property (nonatomic, copy) NSString *Merchant_Name_and_Location;
//"Merchant_Name_and_Location" = 9F4E;
@property (nonatomic, copy) NSString *Point_of_Service_POS_EntryMode;
//"Point_of_Service_POS_EntryMode" = 9F39;
@property (nonatomic, copy) NSString *Script_length_Limit;
//"Script_length_Limit" = DF71;
@property (nonatomic, copy) NSString *TAC_Default;
//"TAC_Default" = DF11;
@property (nonatomic, copy) NSString *TAC_Denial;
//"TAC_Denial" = DF13;
@property (nonatomic, copy) NSString *TAC_Online;
//"TAC_Online" = DF12;
@property (nonatomic, copy) NSString *Target_Percentage_to_be_Used_for_Random_Selection;
//"Target_Percentage_to_be_Used_for_Random_Selection" = DF17;
@property (nonatomic, copy) NSString *Terminal_Capabilities;
//"Terminal_Capabilities" = 9F33;
@property (nonatomic, copy) NSString *Terminal_Country_Code;
//"Terminal_Country_Code" = 9F1A;
@property (nonatomic, copy) NSString *Terminal_Default_Transaction_Qualifiers;
//"Terminal_Default_Transaction_Qualifiers" = 9F66;
@property (nonatomic, copy) NSString *Terminal_Floor_Limit;
//"Terminal_Floor_Limit" = 9F1B;
@property (nonatomic, copy) NSString *Terminal_Identification;
//"Terminal_Identification" = 9F1C;
@property (nonatomic, copy) NSString *Terminal_type;
//"Terminal_type" = 9F35;
@property (nonatomic, copy) NSString *Threshold_Value_BiasedRandom_Selection;
//"Threshold_Value_BiasedRandom_Selection" = DF15;
@property (nonatomic, copy) NSString *Transaction_Currency_Code;
//"Transaction_Currency_Code" = 5F2A;
@property(nonatomic,copy) NSString * Transaction_Currency_Exponent;
//"Transaction_Currency_Exponent" = 5F36;
@property (nonatomic, copy) NSString *Transaction_Reference_Currency_Exponent;
//"Transaction_Reference_Currency_Exponent" = 9F3D;
@property (nonatomic, copy) NSString *Transaction_Reference_Currency_Code;
//"Transaction_Reference_Currency_Code" = 9F3C;
@property (nonatomic, copy) NSString *status;
//status = DF73;
@property (nonatomic, copy) NSString *terminal_contactless_offline_floor_limit;
//"terminal_contactless_offline_floor_limit" = DF19;
@property (nonatomic, copy) NSString *terminal_contactless_transaction_limit;
//"terminal_contactless_transaction_limit" = DF20;
@property (nonatomic, copy) NSString *terminal_status_check;
//"terminal_status_check" = DF75;
@property (nonatomic, copy) NSString *terminal_execute_cvm_limit;
//"terminal_execute_cvm_limit" = DF21;
@end
