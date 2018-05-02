Version | Author        | Date       | Description
--------|---------------|------------|----------------
1.0     | Wenluo Wang   | 2018-05-02 | Initially Added
1.1     | Wenluo Wang   | 2018-05-02 | Added UpdateEmvApp/UpdateEmvCapk API description

## Update EMV cards configure API

You can use the function [pos updateEMVAPP:(operationType) data:data] to set EMV app of your own terminal.

<details>
<summary>updateEMVAPP</summary>
<pre> <code>
-(void)updateEmvAPP:(NSInteger )operationType data:(NSMutableDictionary*)data  block:(void (^)(BOOL isSuccess, NSString *stateStr))updateEMVAPPBlock;
Parameters: 
1.operationType:
  EMVOperation_clear:delete all the aids and the related configures
  EMVOperation_add: add a certain aid and its configures;you can only add one aid each time.
  EMVOperation_update: update a certain tag
  EMVOperation_getList:get all the aids in the terminal
2.data: The data should be an array.
Example Code:
1).Init the emvAppDict;
   NSMutableDictionary * EMVAIDParamDict = [pos getEMVAPPDict];
             
2).Set your own value in the method like what the demo shows:
   NSString * ics  =[[EMVAIDParamDict valueForKey:@"ICS"] 
   stringByAppendingString:[self getEMVStr:@"F4F0F0FAAFFE8000"]];
   
   NSString * terminalType  =[[EMVAIDParamDict valueForKey:@"Terminal_type"] 
   stringByAppendingString:[self getEMVStr:@"22"]];
                     
   NSString * terminalCapbilities =[[EMVAIDParamDict valueForKey:@"Terminal_Capabilities"] 
   stringByAppendingString:[self getEMVStr:@"60B8C8"]];
   ....
   and add all these values into EMVAIDParamDict. 
   ##[pos updateEmvAPP:EMVOperation_add data:EMVAIDParamDict ...];

</code> </pre>
</details>


                    
                     

