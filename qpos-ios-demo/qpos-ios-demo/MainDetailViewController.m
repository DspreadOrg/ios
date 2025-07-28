//
//  MainDetailViewController.m
//  qpos-ios-demo
//
//  Created by Robin on 11/19/13.
//  Copyright (c) 2013 Robin. All rights reserved.
//
#import <MediaPlayer/MPMusicPlayerController.h>
#import "MainDetailViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "QPOSUtil.h"
#import "TLVParser.h"
#import <CommonCrypto/CommonCrypto.h>
#import "Trace.h"
typedef enum : NSUInteger {
    EMVAppXMl,
    EMVCapkXMl,
} EMVXML;

@interface MainDetailViewController ()
@property (nonatomic,copy)NSString *terminalTime;
@property (nonatomic,copy)NSString *currencyCode;
@property (weak, nonatomic) IBOutlet UILabel *labSDK;
@property (weak, nonatomic) IBOutlet UIButton *btnStart;
@property (weak, nonatomic) IBOutlet UIButton *btnGetPosId;
@property (weak, nonatomic) IBOutlet UIButton *btnGetPosInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnDisconnect;
@property (weak, nonatomic) IBOutlet UIButton *btnUpdateEMV;
@property (nonatomic,assign) BOOL updateFWFlag;
@property (nonatomic,strong) NSDictionary *pinDataDict;
@property (nonatomic,copy) NSString *pin;
@property (nonatomic,assign) BOOL isUpdateEMVByXML;
@end

@implementation MainDetailViewController{
    QPOSService *pos;
    PosType     mPosType;
    dispatch_queue_t self_queue;
    TransactionType mTransType;
    NSString *msgStr;
}

@synthesize bluetoothAddress;
@synthesize amount;
@synthesize cashbackAmount;

#pragma mart - sdk delegate

- (void)configureView{
    // Update the user interface for the detail item.
    if (self.detailItem) {
        NSString *aStr = [self.detailItem description];
        self.bluetoothAddress = aStr;
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    self.btnDisconnect.layer.cornerRadius = 10;
    self.btnStart.layer.cornerRadius = 10;
    self.btnGetPosId.layer.cornerRadius = 10;
    self.btnGetPosInfo.layer.cornerRadius = 10;
    self.btnResetPos.layer.cornerRadius = 10;
    self.btnUpdateEMV.layer.cornerRadius = 10;
    self.pinDataDict = [NSDictionary dictionary];
    self.isUpdateEMVByXML = false;
    if (nil == pos) {
        pos = [QPOSService sharedInstance];
    }
    [pos setDelegate:self];
    self.labSDK.text =[@"V" stringByAppendingString:[pos getSdkVersion]];
    
    [pos setQueue:nil];
    if (_detailItem == nil || [_detailItem  isEqual: @""]) {
        self.bluetoothAddress = @"audioType";
    }
    if([self.bluetoothAddress isEqualToString:@"audioType"]){
        [self.btnDisconnect setHidden:YES];
        mPosType = PosType_AUDIO;
        [pos setPosType:PosType_AUDIO];
        [pos startAudio];
        MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
        mpc.volume = .7;
    }else{
        mPosType = PosType_BLUETOOTH_2mode;
        [pos setPosType:PosType_BLUETOOTH_2mode];
        self.textViewLog.text = NSLocalizedString(@"connecting bluetooth...", nil);
        [pos connectBT:self.bluetoothAddress];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    if (mPosType == PosType_AUDIO) {
        Trace(@"viewDidDisappear stop audio");
        [pos stopAudio];
    }else if(mPosType == PosType_BLUETOOTH || mPosType == PosType_BLUETOOTH_new || mPosType == PosType_BLUETOOTH_2mode){
        Trace(@"viewDidDisappear disconnect buluetooth");
        [pos disconnectBT];
    }
}

//pos connect bluetooth callback
-(void) onRequestQposConnected{
    Trace(@"onRequestQposConnected");
    if ([self.bluetoothAddress  isEqual: @"audioType"]) {
        self.textViewLog.text = NSLocalizedString( @"AudioType connected.", nil);
    }else{
        self.textViewLog.text = NSLocalizedString(@"Bluetooth connected.", nil);
    }
}

//disconnect bluetooth
- (IBAction)disconnect:(id)sender {
    [pos disconnectBT];
}

//connect bluetooth fail
-(void) onRequestQposDisconnected{
    Trace(@"onRequestQposDisconnected");
    self.textViewLog.text = NSLocalizedString(@"pos disconnected.", nil);
}

//No Qpos Detected
-(void) onRequestNoQposDetected{
    Trace(@"onRequestNoQposDetected");
    self.textViewLog.text = NSLocalizedString(@"No pos detected.", nil);
}

//start do trade button
- (IBAction)doTrade:(id)sender {
    Trace(@"doTrade");
    self.textViewLog.text = NSLocalizedString(@"Starting...", nil);
    _currencyCode = @"0156";
    [pos setCardTradeMode:CardTradeMode_SWIPE_TAP_INSERT_CARD];
    [pos doCheckCard:30];
}

//input transaction amount
-(void) onRequestSetAmount{
    Trace(@"onRequestSetAmount");
    msgStr = @"Please set amount";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please set amount", nil) message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [pos cancelSetAmount];
        Trace(@"cancel Set Amount");
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取第1个输入框；
        UITextField *titleTextField = alertController.textFields.firstObject;
        NSString *inputAmount = titleTextField.text;
        Trace(@"inputAmount = %@",inputAmount);
        self.lableAmount.text = [NSString stringWithFormat:@"$%@", [self checkAmount:inputAmount]];
        [pos setAmount:inputAmount aAmountDescribe:@"123" currency:_currencyCode transactionType:TransactionType_GOODS];
        self.amount = [NSString stringWithFormat:@"%@", [self checkAmount:inputAmount]];
        self.cashbackAmount = @"123";
    }]];
    [alertController addTextFieldWithConfigurationHandler:nil];
    [self presentViewController:alertController animated:YES completion:nil];
}

//callback of input pin on phone
-(void) onRequestPinEntry{
    Trace(@"onRequestPinEntry");
    self.pin = @"";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please set pin", nil) message:@"" preferredStyle:UIAlertControllerStyleAlert];
    // Add the text field for the secure text entry.
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // Listen for changes to the text field's text so that we can toggle the current
        // action's enabled property based on whether the user has entered a sufficiently
        // secure entry.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
        textField.secureTextEntry = YES;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [pos cancelPinEntry];
        Trace(@"cancel pin entry");
        // Stop listening for text changed notifications.
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertController.textFields.firstObject];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *pinblock = [self buildISO4PinBlock:self.pin dict:pos.getEncryptDataDict];
        NSData *dataPin = [pinblock dataUsingEncoding:NSUTF8StringEncoding];
        [pos sendCvmPin:(Byte *)[dataPin bytes] pinLen:dataPin.length isEncrypted:YES];
        // Stop listening for text changed notifications.
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertController.textFields.firstObject];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    NSString *pinStr = textField.text;
    NSString *cvmKeyList = pos.getCvmKeyList;
    NSString *newPin = @"";
    if(![@"" isEqualToString:cvmKeyList] && ![@"" isEqualToString:pinStr]){
        cvmKeyList = [QPOSUtil asciiFormatString:[QPOSUtil HexStringToByteArray:cvmKeyList]];
        for (NSInteger i = 0; i < pinStr.length; i++) {
            NSRange range = [cvmKeyList rangeOfString:[pinStr substringWithRange:NSMakeRange(i, 1)]];
            newPin = [newPin stringByAppendingString:[QPOSUtil getHexByDecimal:range.location]];
        }
    }
    self.pin = newPin;
    Trace(@"newPin: %@",self.pin);
}

// Prompt user to insert/swipe/tap card
-(void) onRequestWaitingUser{
    Trace(@"onRequestWaitingUser");
    self.textViewLog.text = NSLocalizedString(@"Please insert/swipe/tap card now.", nil);
}

//return NFC and swipe card data on this function.
-(void) onDoTradeResult: (DoTradeResult)result DecodeData:(NSDictionary*)decodeData{
    Trace(@"onDoTradeResult: %@", decodeData);
    if (result == DoTradeResult_NONE) {
        self.textViewLog.text = NSLocalizedString(@"No card detected", nil);
        Trace(@"onDoTradeResult: %@", self.textViewLog.text);
        [pos doTrade:30];
    }else if (result==DoTradeResult_ICC) {
        self.textViewLog.text = NSLocalizedString(@"ICC Card Inserted", nil);
        Trace(@"onDoTradeResult: %@", self.textViewLog.text);
        //Use this API to activate chip card transactions
        [pos doEmvApp:EmvOption_START];
    }else if(result==DoTradeResult_NOT_ICC){
        self.textViewLog.text = NSLocalizedString(@"Card Inserted (Not ICC)", nil);
        Trace(@"onDoTradeResult: %@", self.textViewLog.text);
    }else if(result==DoTradeResult_MCR){
        NSString *formatID = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"Format ID", nil),decodeData[@"formatID"]] ;
        NSString *maskedPAN = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"Masked PAN", nil),decodeData[@"maskedPAN"]];
        NSString *expiryDate = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"Expiry Date", nil),decodeData[@"expiryDate"]];
        NSString *cardHolderName = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"Cardholder Name", nil),decodeData[@"cardholderName"]];
        NSString *serviceCode = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"Service Code", nil),decodeData[@"serviceCode"]];
        NSString *encTrack1 = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"Encrypted Track 1", nil),decodeData[@"encTrack1"]];
        NSString *encTrack2 = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"Encrypted Track 2", nil),decodeData[@"encTrack2"]];
        NSString *encTrack3 = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"Encrypted Track 3", nil),decodeData[@"encTrack3"]];
        NSString *pinKsn = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"PIN KSN", nil),decodeData[@"pinKsn"]];
        NSString *trackksn = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"Track KSN", nil),decodeData[@"trackksn"]];
        NSString *pinBlock = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"pinBlock", nil),decodeData[@"pinBlock"]];
        NSString *encPAN = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"encPAN", nil),decodeData[@"encPAN"]];
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Card Swiped:\n", nil)];
        msg = [msg stringByAppendingString:formatID];
        msg = [msg stringByAppendingString:maskedPAN];
        msg = [msg stringByAppendingString:expiryDate];
        msg = [msg stringByAppendingString:cardHolderName];
        msg = [msg stringByAppendingString:pinKsn];
        msg = [msg stringByAppendingString:trackksn];
        msg = [msg stringByAppendingString:serviceCode];
        msg = [msg stringByAppendingString:encTrack1];
        msg = [msg stringByAppendingString:encTrack2];
        msg = [msg stringByAppendingString:encTrack3];
        msg = [msg stringByAppendingString:pinBlock];
        msg = [msg stringByAppendingString:encPAN];
        NSString *a = [QPOSUtil byteArray2Hex:[QPOSUtil stringFormatTAscii:maskedPAN]];
        [pos getPin:1 keyIndex:0 maxLen:6 typeFace:@"Pls Input Pin" cardNo:a data:@"" delay:30 withResultBlock:^(BOOL isSuccess, NSDictionary *result) {
            Trace(@"result: %@",result);
            self.textViewLog.backgroundColor = [UIColor greenColor];
            [self playAudio];
            AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
            self.textViewLog.text = msg;
            self.lableAmount.text = @"";
        }];
        Trace(@"onDoTradeResult: %@", self.textViewLog.text);
    }else if(result==DoTradeResult_NFC_OFFLINE || result == DoTradeResult_NFC_ONLINE){
        NSString *formatID = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"Format ID", nil),decodeData[@"formatID"]] ;
        NSString *maskedPAN = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"Masked PAN", nil),decodeData[@"maskedPAN"]];
        NSString *expiryDate = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"Expiry Date", nil),decodeData[@"expiryDate"]];
        NSString *cardHolderName = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"Cardholder Name", nil),decodeData[@"cardholderName"]];
        NSString *serviceCode = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"Service Code", nil),decodeData[@"serviceCode"]];
        NSString *encTrack1 = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"Encrypted Track 1", nil),decodeData[@"encTrack1"]];
        NSString *encTrack2 = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"Encrypted Track 2", nil),decodeData[@"encTrack2"]];
        NSString *encTrack3 = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"Encrypted Track 3", nil),decodeData[@"encTrack3"]];
        NSString *pinKsn = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"PIN KSN", nil),decodeData[@"pinKsn"]];
        NSString *trackksn = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"Track KSN", nil),decodeData[@"trackksn"]];
        NSString *pinBlock = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"pinBlock", nil),decodeData[@"pinBlock"]];
        NSString *encPAN = [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"encPAN", nil),decodeData[@"encPAN"]];
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Tap Card:\n", nil)];
        msg = [msg stringByAppendingString:formatID];
        msg = [msg stringByAppendingString:maskedPAN];
        msg = [msg stringByAppendingString:expiryDate];
        msg = [msg stringByAppendingString:cardHolderName];
        msg = [msg stringByAppendingString:pinKsn];
        msg = [msg stringByAppendingString:trackksn];
        msg = [msg stringByAppendingString:serviceCode];
        msg = [msg stringByAppendingString:encTrack1];
        msg = [msg stringByAppendingString:encTrack2];
        msg = [msg stringByAppendingString:encTrack3];
        msg = [msg stringByAppendingString:pinBlock];
        msg = [msg stringByAppendingString:encPAN];
        
        [pos getNFCBatchData:^(NSDictionary *dict) {
            NSString *tlv;
            if(dict !=nil){
                tlv= [NSString stringWithFormat:@"%@: %@\n",NSLocalizedString(@"NFCBatchData", nil),dict[@"tlv"]];
            }else{
                tlv = @"";
            }
            self.textViewLog.backgroundColor = [UIColor greenColor];
            [self playAudio];
            AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
            self.textViewLog.text = [msg stringByAppendingString:tlv];
            self.lableAmount.text = @"";
            Trace(@"onDoTradeResult: %@", self.textViewLog.text);
        }];
//        [pos sendNfcProcessResult:@"8A02303091106C741A0100F69FF96C741A0100F69FF9720F860D84240000082129027736EDDA04"];
    }else if(result==DoTradeResult_NFC_DECLINED){
        self.textViewLog.text = NSLocalizedString(@"Tap Card Declined", nil);
        Trace(@"onDoTradeResult: %@", self.textViewLog.text);
    }else if (result==DoTradeResult_NO_RESPONSE){
        self.textViewLog.text = NSLocalizedString(@"Check card no response", nil);
        Trace(@"onDoTradeResult: %@", self.textViewLog.text);
    }else if(result==DoTradeResult_BAD_SWIPE){
        self.textViewLog.text = NSLocalizedString(@"Bad Swipe. \nPlease swipe again and press check card.", nil);
        Trace(@"onDoTradeResult: %@", self.textViewLog.text);
    }else if(result==DoTradeResult_NO_UPDATE_WORK_KEY){
        self.textViewLog.text = NSLocalizedString(@"Device not update work key", nil);
        Trace(@"onDoTradeResult: %@", self.textViewLog.text);
    }else if(result==DoTradeResult_CARD_NOT_SUPPORT){
        self.textViewLog.text = NSLocalizedString(@"Card not support", nil);
        Trace(@"onDoTradeResult: %@", self.textViewLog.text);
    }else if(result==DoTradeResult_PLS_SEE_PHONE){
        self.textViewLog.text = NSLocalizedString(@"Please see phone", nil);
        Trace(@"onDoTradeResult: %@", self.textViewLog.text);
    }else if(result==DoTradeResult_TRY_ANOTHER_INTERFACE){
        self.textViewLog.text = NSLocalizedString(@"Please try another interface", nil);
        Trace(@"onDoTradeResult: %@", self.textViewLog.text);
    }
}

- (void)playAudio{
    if(![self.bluetoothAddress isEqualToString:@"audioType"]){
        SystemSoundID soundID;
        NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"1801" ofType:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
        AudioServicesPlaySystemSound(soundID);
    }
}

//send current transaction time to pos
-(void) onRequestTime{
    Trace(@"onRequestTime");
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containA.location != NSNotFound;
    //when phone time is 12h format, need add this judgement.
    if (hasAMPM) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
        _terminalTime = [dateFormatter stringFromDate:[NSDate date]];
    }else{
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        _terminalTime = [dateFormatter stringFromDate:[NSDate date]];
    }
    [pos sendTime:_terminalTime];
}

//Prompt message
-(void) onRequestDisplay: (Display)displayMsg{
    NSString *msg = @"";
    if (displayMsg==Display_CLEAR_DISPLAY_MSG) {
        msg = @"";
    }else if(displayMsg==Display_PLEASE_WAIT){
        msg = NSLocalizedString(@"Please wait...", nil);
    }else if(displayMsg==Display_REMOVE_CARD){
        msg = NSLocalizedString(@"Please remove card", nil);
    }else if (displayMsg==Display_TRY_ANOTHER_INTERFACE){
        msg = NSLocalizedString(@"Please try another interface", nil);
    }else if (displayMsg == Display_TRANSACTION_TERMINATED){
        msg = NSLocalizedString(@"Terminated", nil);
    }else if (displayMsg == Display_PIN_OK){
        msg = @"Pin ok";
    }else if (displayMsg == Display_INPUT_PIN_ING){
        msg = NSLocalizedString(@"please input pin on pos", nil);
    }else if (displayMsg == Display_MAG_TO_ICC_TRADE){
        msg = NSLocalizedString(@"please insert chip card on pos", nil);
    }else if (displayMsg == Display_INPUT_OFFLINE_PIN_ONLY){
        msg = NSLocalizedString(@"please input offline pin only", nil);
    }else if(displayMsg == Display_CARD_REMOVED){
        msg = NSLocalizedString(@"Card Removed", nil);
    }else if (displayMsg == Display_INPUT_LAST_OFFLINE_PIN){
        msg = NSLocalizedString(@"please input last offline pin", nil);
    }else if (displayMsg == Display_PROCESSING){
        msg = NSLocalizedString(@"processing...", nil);
    }
    self.textViewLog.text = msg;
    Trace(@"onRequestDisplay: %@", msg);
}

//Multiple AIDS select
-(void) onRequestSelectEmvApp: (NSArray*)appList{
    Trace(@"onRequestSelectEmvApp: %@", appList);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please select app", nil) message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        Trace(@"cancel select app");
        [pos cancelSelectEmvApp];
    }]];
    for (int i=0 ; i<[appList count] ; i++){
        Trace(@"i = %d", i);
        NSString *emvApp = [appList objectAtIndex:i];
        [alertController addAction:[UIAlertAction actionWithTitle:emvApp style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            Trace(@"action: %@ i = %d", action.title, i);
            [pos selectEmvApp:i];
        }]];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

//return chip card tlv data on this function
-(void) onRequestOnlineProcess: (NSString*) tlv{
    Trace(@"onRequestOnlineProcess = %@",[[QPOSService sharedInstance] anlysEmvIccData:tlv]);
/*
    [pos calculateMacWithKey:KeyPart_KEY_ALL cryptMode:CryptMode_CBC_ENCRYPT keyManager:KeyManager_DUKPT_KEY keyType:KeyType_TRACK_KEY data:@"22222222222222222222222222222222" resultBlock:^(NSDictionary *dataDict) {
        Trace(@"dataDict: %@",dataDict);
    }];
    NSArray *dict = [TLVParser parse:tlv];
    for (TLV *tlv in dict) {
        Trace(@"tag: %@ length: %@ value: %@",tlv.tag,tlv.length,tlv.value);
    }
    [pos getEncryptedTrack2Data:^(NSString *ksn, NSString *track2Data) {
        Trace(@"ksn: %@ track2Data: %@",ksn,track2Data);
    }];
*/
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Request data to server.", nil) message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //send transaction to bank and request bank approval
        [pos cancelTrade:true];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //send transaction to bank and request bank approval
        [pos sendOnlineProcessResult:@"8A023030"];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

// transaction result callback function
-(void) onRequestTransactionResult: (TransactionResult)transactionResult{
    NSString *messageTextView = @"";
    if (transactionResult==TransactionResult_APPROVED) {
        NSString *message = [NSString stringWithFormat:@"%@\n%@: $%@\n",NSLocalizedString(@"Approved", nil),NSLocalizedString(@"Amount", nil),amount];
        if(![cashbackAmount isEqualToString:@""]) {
            message = [message stringByAppendingFormat:@"%@: $",NSLocalizedString(@"Cashback", nil)];
            message = [message stringByAppendingString:cashbackAmount];
        }
        messageTextView = message;
        self.textViewLog.backgroundColor = [UIColor greenColor];
        [self playAudio];
    }else if(transactionResult == TransactionResult_TERMINATED) {
        [self clearDisplay];
        messageTextView = NSLocalizedString(@"Terminated", nil);
    } else if(transactionResult == TransactionResult_DECLINED) {
        messageTextView = NSLocalizedString(@"Declined", nil);
    } else if(transactionResult == TransactionResult_CANCEL) {
        [self clearDisplay];
        messageTextView = NSLocalizedString(@"Cancel", nil);
    } else if(transactionResult == TransactionResult_CAPK_FAIL) {
        [self clearDisplay];
        messageTextView = NSLocalizedString(@"Fail (CAPK fail)", nil);
    } else if(transactionResult == TransactionResult_NOT_ICC) {
        [self clearDisplay];
        messageTextView = NSLocalizedString(@"Card Inserted (Not ICC)", nil);
    } else if(transactionResult == TransactionResult_SELECT_APP_FAIL) {
        [self clearDisplay];
        messageTextView = NSLocalizedString(@"Fail (App fail)", nil);
    } else if(transactionResult == TransactionResult_DEVICE_ERROR) {
        [self clearDisplay];
        messageTextView = NSLocalizedString(@"Pos Error", nil);
    } else if(transactionResult == TransactionResult_CARD_NOT_SUPPORTED) {
        [self clearDisplay];
        messageTextView = NSLocalizedString(@"Card not support", nil);
    } else if(transactionResult == TransactionResult_MISSING_MANDATORY_DATA) {
        [self clearDisplay];
        messageTextView = NSLocalizedString(@"Missing mandatory data", nil);
    } else if(transactionResult == TransactionResult_CARD_BLOCKED_OR_NO_EMV_APPS) {
        [self clearDisplay];
        messageTextView = NSLocalizedString(@"Card blocked or no EMV apps", nil);
    } else if(transactionResult == TransactionResult_INVALID_ICC_DATA) {
        [self clearDisplay];
        messageTextView = NSLocalizedString(@"Invalid ICC data", nil);
    }else if(transactionResult == TransactionResult_NFC_TERMINATED) {
        [self clearDisplay];
        messageTextView = NSLocalizedString(@"NFC Terminated", nil);
    }else if(transactionResult == TransactionResult_CONTACTLESS_TRANSACTION_NOT_ALLOW) {
        [self clearDisplay];
        messageTextView = NSLocalizedString(@"TRANS NOT ALLOW", nil);
    }else if(transactionResult == TransactionResult_CARD_BLOCKED) {
        [self clearDisplay];
        messageTextView = NSLocalizedString(@"Card Blocked", nil);
    }else if(transactionResult == TransactionResult_TOKEN_INVALID) {
        [self clearDisplay];
        messageTextView = NSLocalizedString(@"Token Invalid", nil);
    }else if(transactionResult == TransactionResult_APP_BLOCKED) {
        [self clearDisplay];
        messageTextView = NSLocalizedString(@"APP Blocked", nil);
    }else if(transactionResult == TransactionResult_MULTIPLE_CARDS) {
        [self clearDisplay];
        messageTextView = NSLocalizedString(@"Multiple Cards", nil);
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Transaction Result", nil) message:messageTextView preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    self.amount = @"";
    self.cashbackAmount = @"";
    self.lableAmount.text = @"";
    msgStr = @"Transaction Result";
    Trace(@"onRequestTransactionResult: %@",messageTextView);
}

-(void) onRequestTransactionLog: (NSString*)tlv{
    Trace(@"onTransactionLog %@",tlv);
}

//return transaction batch data
-(void) onRequestBatchData: (NSString*)tlv{
    Trace(@"onBatchData %@",tlv);
    tlv = [NSString stringWithFormat:@"%@:\n%@",NSLocalizedString(@"batch data", nil),tlv];
    self.textViewLog.text = tlv;
}

//return transaction reversal data
-(void) onReturnReversalData: (NSString*)tlv{
    Trace(@"onReversalData %@",tlv);
    tlv = [NSString stringWithFormat:@"%@:\n%@",NSLocalizedString(@"reversal data", nil),tlv];
    self.textViewLog.text = tlv;
}

-(void) onEmvICCExceptionData: (NSString*)tlv{
    Trace(@"onEmvICCExceptionData:%@",tlv);
    tlv = [NSString stringWithFormat:@"%@:\n%@",NSLocalizedString(@"onEmvICCExceptionData", nil),tlv];
    self.textViewLog.text = tlv;
}

//cancel transaction api.
- (IBAction)cancelTransactionAction:(id)sender {
    Trace(@"cancel Transaction");
    self.textViewLog.backgroundColor = [UIColor greenColor];
    self.textViewLog.text = NSLocalizedString(@"cancel trade ... ", nil);
    [pos cancelTrade];
}

- (void)onTradeCancelled{
    self.textViewLog.text = NSLocalizedString(@"cancel trade success", nil);
}

//Prompt error message in this function
-(void) onDHError: (DHError)errorState{
    [self dismissViewControllerAnimated:YES completion:nil]; // 关闭弹窗
    NSString *msg = @"";
    if(errorState ==DHError_TIMEOUT) {
        msg = NSLocalizedString(@"Pos no response", nil);
    } else if(errorState == DHError_DEVICE_RESET) {
        msg = NSLocalizedString(@"Pos reset", nil);
    } else if(errorState == DHError_UNKNOWN) {
        msg = NSLocalizedString(@"Unknown error", nil);
    } else if(errorState == DHError_DEVICE_BUSY) {
        msg = NSLocalizedString(@"Pos Busy", nil);
    } else if(errorState == DHError_INPUT_OUT_OF_RANGE) {
        msg = NSLocalizedString(@"Input out of range.", nil);
        [pos resetPosStatus];
    } else if(errorState == DHError_INPUT_INVALID_FORMAT) {
        msg = NSLocalizedString(@"Input invalid format", nil);
    } else if(errorState == DHError_INPUT_ZERO_VALUES) {
        msg = NSLocalizedString(@"Input are zero values", nil);
    } else if(errorState == DHError_INPUT_INVALID) {
        msg = NSLocalizedString(@"Input invalid", nil);
    } else if(errorState == DHError_CASHBACK_NOT_SUPPORTED) {
        msg = NSLocalizedString(@"Cashback not supported", nil);
    } else if(errorState == DHError_CRC_ERROR) {
        msg = NSLocalizedString(@"CRC Error", nil);
    } else if(errorState == DHError_COMM_ERROR) {
        msg = NSLocalizedString(@"Communication Error", nil);
    }else if(errorState == DHError_MAC_ERROR){
        msg = NSLocalizedString(@"MAC Error", nil);
    }else if(errorState == DHError_CMD_TIMEOUT){
        msg = NSLocalizedString(@"CMD Timeout", nil);
    }else if(errorState == DHError_AMOUNT_OUT_OF_LIMIT){
        msg = NSLocalizedString(@"Amount out of limit", nil);
    }else{
        msg = NSLocalizedString(@"Not implemented", nil);
    }
    self.textViewLog.text = msg;
    Trace(@"onError = %@",msg);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertController dismissViewControllerAnimated:YES completion:nil];
    });
}

//get pos id in this function.
- (IBAction)getQposId:(id)sender {
    Trace(@"getQposId");
    [pos getQPosId];
}

// callback function of getQposId api
-(void) onQposIdResult: (NSDictionary*)posId{
    NSString *aStr = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"posId", nil),posId[@"posId"]];
    NSString *temp = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"psamId", nil),posId[@"psamId"]];
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:temp];
    
    temp = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"merchantId", nil),posId[@"merchantId"]];
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:temp];
    
    temp = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"vendorCode", nil),posId[@"vendorCode"]];
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:temp];
    
    temp = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"deviceNumber", nil),posId[@"deviceNumber"]];
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:temp];
    
    temp = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"psamNo", nil),posId[@"psamNo"]];
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:temp];
    
    temp = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"isSupportNFC", nil),posId[@"isSupportNFC"]];
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:temp];
    
    self.textViewLog.text = aStr;
    Trace(@"onQposIdResult: %@",aStr);
}

//get pos info function
- (IBAction)getPosInfo:(id)sender {
    Trace(@"getPosInfo");
   [pos getQPosInfo];
}

//callback function of getPosInfo api.
-(void) onQposInfoResult: (NSDictionary*)posInfoData{
    if (self.isUpdateEMVByXML) {
        NSString *xmlStr = @"";
        NSData *xmlData = [NSData data];
        NSString *deviceModel = posInfoData[@"ModelInfo"];
        if (deviceModel == nil || deviceModel.length == 0) {
            xmlData = [self readLine:@"QPOS cute,CR100,D20,D30"];
        }else if([@"QPOSMINI" isEqualToString:deviceModel] || [@"QPOSULTRA" isEqualToString:deviceModel]){
            xmlData = [self readLine:@"QPOS mini"];
        }else{
            xmlData = [self readLine:@"QPOS cute,CR100,D20,D30"];
        }
        xmlStr = [QPOSUtil asciiFormatString:xmlData];
        [pos updateEMVConfigByXml:xmlStr];
        self.isUpdateEMVByXML = false;
    }else{
        NSString *aStr = [NSString stringWithFormat:@"%@: ",NSLocalizedString(@"BootloaderVersion", nil)];
        aStr = [aStr stringByAppendingString:posInfoData[@"bootloaderVersion"]];
        
        aStr = [aStr stringByAppendingString:@"\n"];
        aStr = [NSString stringWithFormat:@"%@%@: ",aStr,NSLocalizedString(@"FirmwareVersion", nil)];
        aStr = [aStr stringByAppendingString:posInfoData[@"firmwareVersion"]];
        
        aStr = [aStr stringByAppendingString:@"\n"];
        aStr = [NSString stringWithFormat:@"%@%@: ",aStr,NSLocalizedString(@"HardwareVersion", nil)];
        aStr = [aStr stringByAppendingString:posInfoData[@"hardwareVersion"]];
        
        NSString *batteryPercentage = posInfoData[@"batteryPercentage"];
        if (batteryPercentage==nil || [@"" isEqualToString:batteryPercentage]) {
            aStr = [aStr stringByAppendingString:@"\n"];
            aStr = [NSString stringWithFormat:@"%@%@: ",aStr,NSLocalizedString(@"BatteryLevel", nil)];
            aStr = [aStr stringByAppendingString:posInfoData[@"batteryPercentage"]];
        }else{
            aStr = [aStr stringByAppendingString:@"\n"];
            aStr = [NSString stringWithFormat:@"%@%@: ",aStr,NSLocalizedString(@"BatteryLevel", nil)];
            aStr = [aStr stringByAppendingString:posInfoData[@"batteryPercentage"]];
        }
        aStr = [aStr stringByAppendingString:@"\n"];
        aStr = [NSString stringWithFormat:@"%@%@: ",aStr,NSLocalizedString(@"isCharging", nil)];
        aStr = [aStr stringByAppendingString:posInfoData[@"isCharging"]];
        
        aStr = [aStr stringByAppendingString:@"\n"];
        aStr = [NSString stringWithFormat:@"%@%@: ",aStr,NSLocalizedString(@"isUsbConnected", nil)];
        aStr = [aStr stringByAppendingString:posInfoData[@"isUsbConnected"]];
        
        aStr = [aStr stringByAppendingString:@"\n"];
        aStr = [NSString stringWithFormat:@"%@%@: ",aStr,NSLocalizedString(@"isSupportedTrack1", nil)];
        aStr = [aStr stringByAppendingString:posInfoData[@"isSupportedTrack1"]];
        
        aStr = [aStr stringByAppendingString:@"\n"];
        aStr = [NSString stringWithFormat:@"%@%@: ",aStr,NSLocalizedString(@"isSupportedTrack2", nil)];
        aStr = [aStr stringByAppendingString:posInfoData[@"isSupportedTrack2"]];
        
        aStr = [aStr stringByAppendingString:@"\n"];
        aStr = [NSString stringWithFormat:@"%@%@: ",aStr,NSLocalizedString(@"isSupportedTrack3", nil)];
        aStr = [aStr stringByAppendingString:posInfoData[@"isSupportedTrack3"]];
        
        aStr = [aStr stringByAppendingString:@"\n"];
        aStr = [NSString stringWithFormat:@"%@%@: ",aStr,NSLocalizedString(@"updateWorkKeyFlag", nil)];
        aStr = [aStr stringByAppendingString:posInfoData[@"updateWorkKeyFlag"]];
        
        aStr = [aStr stringByAppendingString:@"\n"];
        aStr = [NSString stringWithFormat:@"%@%@: ",aStr,NSLocalizedString(@"ModelInfo", nil)];
        aStr = [aStr stringByAppendingString:posInfoData[@"ModelInfo"]];
        
        self.textViewLog.text = aStr;
        Trace(@"onQposInfoResult: %@",aStr);
    }
}

- (void)onRequestGetCardNoResult:(NSString *)result{
    Trace(@"card no: %@",result);
    [pos doEmvApp:EmvOption_START];
}

- (void)showLoadingDialog:(NSString *)message {
    // 创建 UIAlertController
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:NSLocalizedString(message, nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    // 显示弹窗
    [self presentViewController:alertController animated:YES completion:nil];
}

//eg: update TMK api in pos.
-(void)setMasterKey:(NSInteger)keyIndex{
    Trace(@"setMasterKey");
    NSString *pik = @"89EEF94D28AA2DC189EEF94D28AA2DC1";//111111111111111111111111
    NSString *pikCheck = @"82E13665B4624DF5";
    pik = @"F679786E2411E3DEF679786E2411E3DE";//33333333333333333333333333333
    pikCheck = @"ADC67D8473BF2F06";
    [pos setMasterKey:pik checkValue:pikCheck keyIndex:keyIndex];
}
// callback function of setMasterKey api
-(void) onReturnSetMasterKeyResult: (BOOL)isSuccess{
    if(isSuccess){
        self.textViewLog.text = @"Success";
    }else{
        self.textViewLog.text =  @"Failed";
    }
    Trace(@"onReturnSetMasterKeyResult: %@",self.textViewLog.text);
}

//eg: update work key in pos.
-(void)updateWorkKey:(NSInteger)keyIndex{
    Trace(@"updateWorkKey");
    NSString * pik = @"89EEF94D28AA2DC189EEF94D28AA2DC1";
    NSString * pikCheck = @"82E13665B4624DF5";
    
    pik = @"89EEF94D28AA2DC189EEF94D28AA2DC1";
    pikCheck = @"82E13665B4624DF5";
    
    NSString * trk = @"89EEF94D28AA2DC189EEF94D28AA2DC1";
    NSString * trkCheck = @"82E13665B4624DF5";
    
    NSString * mak = @"89EEF94D28AA2DC189EEF94D28AA2DC1";
    NSString * makCheck = @"82E13665B4624DF5";
    [pos udpateWorkKey:pik pinKeyCheck:pikCheck trackKey:trk trackKeyCheck:trkCheck macKey:mak macKeyCheck:makCheck keyIndex:keyIndex];
}

// callback function of updateWorkKey api.
-(void) onRequestUpdateWorkKeyResult:(UpdateInformationResult)updateInformationResult{
    if (updateInformationResult==UpdateInformationResult_UPDATE_SUCCESS) {
        self.textViewLog.text = @" update workkey Success";
    }else if(updateInformationResult==UpdateInformationResult_UPDATE_FAIL){
        self.textViewLog.text =  @"Failed";
    }else if(updateInformationResult==UpdateInformationResult_UPDATE_PACKET_LEN_ERROR){
        self.textViewLog.text =  @"Packet len error";
    }else if(updateInformationResult==UpdateInformationResult_UPDATE_PACKET_VEFIRY_ERROR){
        [pos getUpdateCheckValueBlock:^(BOOL isSuccess, NSString *stateStr) {
            self.textViewLog.text = [@"Packet vefiry error " stringByAppendingString:stateStr];
        }];
    }
    Trace(@"onRequestUpdateWorkKeyResult %@",self.textViewLog.text);
}

//update ipek
- (void)updateIpek{
    Trace(@"updateIpek");
     [pos doUpdateIPEKOperation:@"00" tracksn:@"00000510F462F8400004" trackipek:@"293C2D8B1D7ABCF83E665A7C5C6532C9" trackipekCheckValue:@"93906AA157EE2604" emvksn:@"00000510F462F8400004" emvipek:@"293C2D8B1D7ABCF83E665A7C5C6532C9" emvipekcheckvalue:@"93906AA157EE2604" pinksn:@"00000510F462F8400004" pinipek:@"293C2D8B1D7ABCF83E665A7C5C6532C9" pinipekcheckValue:@"93906AA157EE2604" block:^(BOOL isSuccess, NSString *stateStr) {
        if (isSuccess) {
            self.textViewLog.text = stateStr;
        }
    }];
}

//update ipek by key type
- (void)updateIpekByKeyType{
    Trace(@"updateIpekByKeyType");
     [pos updateIPEKOperationByKeyType:@"00" tracksn:@"00000510F462F8400004" trackipek:@"98357D2CA022B6E298357D2CA022B6E2" trackipekCheckValue:@"82E13665B4624DF5" emvksn:@"00000510F462F8400004" emvipek:@"98357D2CA022B6E298357D2CA022B6E2" emvipekcheckvalue:@"82E13665B4624DF5" pinksn:@"" pinipek:@"" pinipekcheckValue:@"" block:^(BOOL isSuccess, NSString *stateStr) {
        if (isSuccess) {
            self.textViewLog.text = stateStr;
        }
    }];
}
- (IBAction)updateEMVConfig:(id)sender {
    [self updateEMVConfigByXML];
}

//eg: read xml file to update emv configure
- (void)updateEMVConfigByXML{
    self.textViewLog.text = NSLocalizedString(@"start update emv configure,pls wait", nil);
    Trace(@"updateEMVConfigByXML,pls wait");
    [self showLoadingDialog:@"updateEMV"];
    self.isUpdateEMVByXML = true;
    [pos getQPosInfo];
}

// callback function of updateEmvConfig and updateEMVConfigByXml api.
-(void)onReturnCustomConfigResult:(BOOL)isSuccess config:(NSString*)resutl{
    [self dismissViewControllerAnimated:YES completion:nil]; // 关闭弹窗
    if(isSuccess){
        self.textViewLog.text = NSLocalizedString(@"Success", nil);
        self.textViewLog.backgroundColor = [UIColor greenColor];
    }else{
        self.textViewLog.text = NSLocalizedString(@"Fail", nil);
    }
    Trace(@"onReturnCustomConfigResult: %@",self.textViewLog.text);
}

- (void)onGetCardInfoResult:(NSDictionary *)cardInfo{
    Trace(@"AID: %@, CardNo: %@", [cardInfo objectForKey:@"AID"],[cardInfo objectForKey:@"CardNo"]);
}

// update pos firmware api
- (IBAction)updatePosFirmware:(UIButton *)sender {
    Trace(@"updatePosFirmware");
    NSData *data = [self readLine:@"A27UC_S1(样机英文版)_master"];//read QPOS_Mini_Firmware.asc
    if (data != nil) {
        [pos updatePosFirmware:data address:self.bluetoothAddress];
        self.updateFWFlag = true;
        dispatch_async(dispatch_queue_create(0, 0), ^{
            while (true) {
                [NSThread sleepForTimeInterval:0.1];
                NSInteger progress = [pos getUpdateProgress];
                if (progress < 100) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!self.updateFWFlag) {
                            return;
                        }
                        self.textViewLog.text = [NSString stringWithFormat:@"Current progress:%ld%%",(long)progress];
                    });
                    continue;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.textViewLog.text = @"finish upgrader";
                });
                break;
            }
        });
    }else{
        self.textViewLog.text = @"pls make sure you have passed the right data";
    }
}

// callback function of updatePosFirmware api.
-(void) onUpdatePosFirmwareResult:(UpdateInformationResult)updateInformationResult{
    Trace(@"%ld",(long)updateInformationResult);
    self.updateFWFlag = false;
    if (updateInformationResult==UpdateInformationResult_UPDATE_SUCCESS) {
        self.textViewLog.text = @"Success";
    }else if(updateInformationResult==UpdateInformationResult_UPDATE_FAIL){
        self.textViewLog.text =  @"Failed";
    }else if(updateInformationResult==UpdateInformationResult_UPDATE_PACKET_LEN_ERROR){
        self.textViewLog.text =  @"Packet len error";
    }else if(updateInformationResult==UpdateInformationResult_UPDATE_PACKET_VEFIRY_ERROR){
        self.textViewLog.text =  @"Packer vefiry error";
    }else if(updateInformationResult==UpdateInformationResult_UPDATE_PLEASE_PLUG_INTO_POWER){
        self.textViewLog.text =  @"Please plug into power";
    }else{
        self.textViewLog.text = @"firmware updating...";
    }
}

- (void)generateTransportKey{
    [pos generateTransportKey:10 dataBlock:^(NSDictionary *dataBlock) {
        NSString *transportKey = [dataBlock objectForKey:@"transportKey"];
        NSString *checkValue = [dataBlock objectForKey:@"checkValue"];
        Trace(@"transportKey: %@, checkValue = %@",transportKey,checkValue);
    }];
}

//get encrypt data function
- (void)getEncryptData{
    NSData *data = [@"123456789" dataUsingEncoding:NSUTF8StringEncoding];;
    [pos getEncryptData:data keyType:@"2" keyIndex:@"0" timeOut:10];
}

- (void)onReturnGetEncryptDataResult:(NSDictionary *)tlv{
    Trace(@"onReturnGetEncryptDataResult: %@", tlv);
}

//update public key into pos
- (void)updateRSATest{
    NSString *pemStr = [QPOSUtil asciiFormatString: [self readLine:@"rsa_public_key_pkcs8_test"]];
    Trace(@"pemStr: %@", pemStr);
    [pos updateRSA:pemStr pemFile:@"rsa_public_key_pkcs8_test.pem"];
}

// callback function of updateRSA function
-(void)onDoSetRsaPublicKey:(BOOL)result{
    Trace(@"onDoSetRsaPublicKey: %d", result);
    if (result) {
        self.textViewLog.text = @"success";
    }else{
        self.textViewLog.text = @"fail";
    }
}

//generate Session Keys from pos
- (void)generateSessionKeysTest{
    [pos generateSessionKeys];
}

-(void)onQposGenerateSessionKeysResult:(NSDictionary *)result{
    Trace(@"onQposGenerateSessionKeysResult: %@", result);
}

-(void) onGetPosComm:(NSInteger)mode amount:(NSString *)amt posId:(NSString*)aPosId{
    if(mode == 1){
        [pos doTrade:30];
    }
}

-(void)clearDisplay{
    self.textViewLog.text = @"";
}

-(NSString *)checkAmount:(NSString *)tradeAmount{
    NSString *rs = @"";
    NSInteger a = 0;
    if (tradeAmount==nil || [tradeAmount isEqualToString:@""]) {
        Trace(@"trade amount is nil or empty");
        return rs;
    }

    if ([tradeAmount hasPrefix:@"0"]) {
        Trace(@"trade amount is invalid");
        return rs;
    }
    
    if (![QPOSUtil isPureInt:tradeAmount]) {
        Trace(@"trade amount is invalid");
        return rs;
    }
    
    a = [tradeAmount length];
    if (a == 1) {
        rs = [@"0.0" stringByAppendingString:tradeAmount];
    }else if (a==2){
        rs = [@"0." stringByAppendingString:tradeAmount];
    }else if(a > 2){
        rs = [tradeAmount substringWithRange:NSMakeRange(0, a-2)];
        rs = [rs stringByAppendingString:@"."];
        rs = [rs stringByAppendingString: [tradeAmount substringWithRange:NSMakeRange(a-2,2)]];
    }
    return rs;
}

- (NSData*)readLine:(NSString*)name{
    NSString* binFile = [[NSBundle mainBundle]pathForResource:name ofType:@".bin"];
    NSString* ascFile = [[NSBundle mainBundle]pathForResource:name ofType:@".asc"];
    NSString* xmlFile = [[NSBundle mainBundle]pathForResource:name ofType:@".xml"];
    NSString* pemFile = [[NSBundle mainBundle]pathForResource:name ofType:@".pem"];
    if (binFile!= nil && ![binFile isEqualToString: @""]) {
        NSFileManager* Manager = [NSFileManager defaultManager];
        NSData* data1 = [[NSData alloc] init];
        data1 = [Manager contentsAtPath:binFile];
        return data1;
    }else if (ascFile!= nil && ![ascFile isEqualToString: @""]){
        NSFileManager* Manager = [NSFileManager defaultManager];
        NSData* data2 = [[NSData alloc] init];
        data2 = [Manager contentsAtPath:ascFile];
        return data2;
    }else if (xmlFile!= nil && ![xmlFile isEqualToString: @""]){
        NSFileManager* Manager = [NSFileManager defaultManager];
        NSData* data2 = [[NSData alloc] init];
        data2 = [Manager contentsAtPath:xmlFile];
        return data2;
    }else if (pemFile!= nil && ![pemFile isEqualToString: @""]){
        NSFileManager* Manager = [NSFileManager defaultManager];
        NSData* data2 = [[NSData alloc] init];
        data2 = [Manager contentsAtPath:pemFile];
        Trace(@"pemFile: %@", pemFile);
        return data2;
    }
    return nil;
}

- (NSString *)buildISO4PinBlock:(NSString *)pin dict:(NSDictionary *)dict{
    NSString *random = [dict objectForKey:@"RandomData"];
    NSString *aesKey = [dict objectForKey:@"AESKey"];
    NSString *pan = [dict objectForKey:@"PAN"];
    NSString *pinStr = [NSString stringWithFormat:@"4%lu%@",pin.length,pin];
    NSInteger pinStrLen = 16 - pinStr.length;
    for (int i = 0; i < pinStrLen; i++) {
        pinStr = [pinStr stringByAppendingString:@"A"];
    }
    NSString *newRandom = [random substringToIndex:16];
    pinStr = [pinStr stringByAppendingString:newRandom];
    NSString *panStr = @"";
    if(pan.length < 12){
        panStr = @"0";
        for (int i = 0; i < 12 - pan.length; i++) {
            [panStr stringByAppendingString:@"0"];
        }
        panStr = [[panStr stringByAppendingString:pan] stringByAppendingString:@"0000000000000000000"];
    }else{
        panStr = [NSString stringWithFormat:@"%lu%@",pan.length - 12,pan];
        NSInteger panLen = 32-panStr.length;
        for (int i = 0; i < panLen; i++) {
           panStr = [panStr stringByAppendingString:@"0"];
        }
    }
    NSString *blockA = [self encryptOperation:kCCEncrypt value:pinStr key:aesKey];
    NSString *blockB = [self pinxCreator:panStr withPinv:blockA];
    NSString *pinblock = [self encryptOperation:kCCEncrypt value:blockB key:aesKey];
    return pinblock;
}

- (NSString *)pinxCreator:(NSString *)pan withPinv:(NSString *)pinv{
    if (pan.length != pinv.length){
        return @"";
    }
    const char *panchar = [pan UTF8String];
    const char *pinvchar = [pinv UTF8String];
    NSString *temp = [[NSString alloc] init];
    for (int i = 0; i < pan.length; i++){
        int panValue = [self charToint:panchar[i]];
        int pinvValue = [self charToint:pinvchar[i]];
        temp = [temp stringByAppendingString:[NSString stringWithFormat:@"%X",panValue^pinvValue]];
    }
    return temp;
}
- (int)charToint:(char)tempChar{
    if (tempChar >= '0' && tempChar <='9'){
        return tempChar - '0';
    }
    else if (tempChar >= 'A' && tempChar <= 'F'){
        return tempChar - 'A' + 10;
    }
    return 0;
}

- (NSString *)encryptOperation:(CCOperation)operation value:(NSString *)data key:(NSString *)key{
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
    } else {
        if (buffer) {
            free(buffer);
            buffer = NULL;
        }
    }
    return nil;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

