*QPOS Programming Guide*


[TOC]

# Change List

Version | Author        | Date       | Description
--------|---------------|------------|----------------
0.1     | Austin Wang   | 2013-05-01 | Initially Added
1.0     | Austin Wang   | 2013-09-01 | Added EMV related function
1.1     | Ausitn Wang   | 2014-03-01 | Merge QPOS standard and EMV Card reader together
1.2     | Austin Wang   | 2014-10-20 | Added UART interface support for GES device

# Introduction

QPOS is a serial of mobile payment devices. It can communicate with the mobile device through audio jack, UART or USB cable. 

QPOS standard, QPOS mini, QPOS Plus, EMV06, EMV08, GEA and GES are all QPOS products, some of them are with PINPAD embedded and some of them are only card readers without PINPAD.

This document aims to help readers for using the Android SDK of QPOS.

# Programming Model

All methods the SDK provided can be devided into three types:
1. Init methods；
2. Interactive methods；
3. Listener methods.

The application use the init method to init the EMV card reader hardware and get an instance of the Card Reader. It then can use the interactive methods to start the communication with the card reader. During the communication process, if any message returned from the Card reader, a listener method will be invoked by the SDK package.

To avoid the application block and improve the speed of  data interaction between the smart terminal and QPOS, the SDK framework is designed to work under asynchronous mode.

# Programming Interface

## Initialization

The Class named ‘QPOSService’ is the core of SDK library. Before the APP create this core instance with the parameter of “Pos Type”, the APP must register all the delegate method in ‘QPOSService’. Below code snipplet shows how to init the SDK.

```objc
	pos = [QPOSService sharedInstance];
	[pos setDelegate:self];
	[pos setQueue:nil];
	mPosType = PosType_BLUETOOTH_2mode;
	[pos setPosType:PosType_BLUETOOTH_2mode];
	[pos setBTAutoDetecting:true];
```

The PosType can be 

```objc
	typedef NS_ENUM(NSInteger, PosType) {
    		PosType_AUDIO,
    		PosType_BLUETOOTH_2mode //bluetooth 2 mode
	};
```
The app should choose appropriate pos type depend on it's hardware configuration.
Note, in the example above the app should realize the delegate methods of QPOSService.

## Get Device Information

The app can get the EMV cardreader information by issuing:

```objc
	[pos getQPosInfo];
```
Note the pos is the instance of QPOSService, the app get it during the initialization process.

The device information will be returned on the below call back:
```objc
	-(void) onQposInfoResult: (NSDictionary*)posInfoData{
		NSString *aStr = @"Bootloader Version: ";
		aStr = [aStr stringByAppendingString:posInfoData[@"bootloaderVersion"]];
		
		aStr = [aStr stringByAppendingString:@"\n"];
		aStr = [aStr stringByAppendingString:@"Firmware Version: "];
		aStr = [aStr stringByAppendingString:posInfoData[@"firmwareVersion"]];
		
		aStr = [aStr stringByAppendingString:@"\n"];
		aStr = [aStr stringByAppendingString:@"Hardware Version: "];
		aStr = [aStr stringByAppendingString:posInfoData[@"hardwareVersion"]];

		NSString *batteryPercentage = posInfoData[@"batteryPercentage"];
		if (batteryPercentage==nil || [@"" isEqualToString:batteryPercentage]) {
			aStr = [aStr stringByAppendingString:@"\n"];
			aStr = [aStr stringByAppendingString:@"Battery Level: "];
			aStr = [aStr stringByAppendingString:posInfoData[@"batteryLevel"]];
		}	else{
			aStr = [aStr stringByAppendingString:@"\n"];
			aStr = [aStr stringByAppendingString:@"Battery Percentage: "];
			Str = [aStr stringByAppendingString:posInfoData[@"batteryPercentage"]];
		}
		aStr = [aStr stringByAppendingString:@"\n"];
		aStr = [aStr stringByAppendingString:@"Charge: "];
		aStr = [aStr stringByAppendingString:posInfoData[@"isCharging"]];
		aStr = [aStr stringByAppendingString:@"\n"];
		aStr = [aStr stringByAppendingString:@"USB: "];
		aStr = [aStr stringByAppendingString:posInfoData[@"isUsbConnected"]];
		
		aStr = [aStr stringByAppendingString:@"\n"];
		aStr = [aStr stringByAppendingString:@"Track 1 Supported: "];
		aStr = [aStr stringByAppendingString:posInfoData[@"isSupportedTrack1"]];
		
		aStr = [aStr stringByAppendingString:@"\n"];
		aStr = [aStr stringByAppendingString:@"Track 2 Supported: "];
		aStr = [aStr stringByAppendingString:posInfoData[@"isSupportedTrack2"]];
		
		aStr = [aStr stringByAppendingString:@"\n"];
		aStr = [aStr stringByAppendingString:@"Track 3 Supported: "];
		aStr = [aStr stringByAppendingString:posInfoData[@"isSupportedTrack3"]];
		
		aStr = [aStr stringByAppendingString:@"\n"];
		aStr = [aStr stringByAppendingString:@"updateWorkKeyFlag: "];
		aStr = [aStr stringByAppendingString:posInfoData[@"updateWorkKeyFlag"]];
	}

```
App can knows the hardware , firmware version and hardware configuration based on the returned information.


## Get Device ID

The device ID is use to indentifying one paticular EMV card reader. The app use below method to get the device ID:

```objc
	[pos getQPosId];
```

The Device ID is returned to the app by below call back.

```objc
	-(void) onQposIdResult: (NSDictionary*)posId{
		NSString *aStr = [@"posId:" stringByAppendingString:posId[@"posId"]];
		
		NSString *temp = [@"psamId:" stringByAppendingString:posId[@"psamId"]];
		aStr = [aStr stringByAppendingString:@"\n"];
		aStr = [aStr stringByAppendingString:temp];
		
		temp = [@"merchantId:" stringByAppendingString:posId[@"merchantId"]];
		aStr = [aStr stringByAppendingString:@"\n"];
		aStr = [aStr stringByAppendingString:temp];
		
		temp = [@"vendorCode:" stringByAppendingString:posId[@"vendorCode"]];
		aStr = [aStr stringByAppendingString:@"\n"];
		aStr = [aStr stringByAppendingString:temp];
		
		temp = [@"deviceNumber:" stringByAppendingString:posId[@"deviceNumber"]];
		aStr = [aStr stringByAppendingString:@"\n"];
		aStr = [aStr stringByAppendingString:temp];
		
		temp = [@"psamNo:" stringByAppendingString:posId[@"psamNo"]];
		aStr = [aStr stringByAppendingString:@"\n"];
		aStr = [aStr stringByAppendingString:temp];
		
		temp = [@"isSupportNFC:" stringByAppendingString:posId[@"isSupportNFC"]];
		aStr = [aStr stringByAppendingString:@"\n"];
		aStr = [aStr stringByAppendingString:temp];
	}

```


## Start Transaction

The app can start a magnatic swipe card transaction, or an EMV chip card transaction, by below method:
```objc
	[pos doTrade(60)];
```
The only paramter is the time out value in second. If the user is using magnatic swipe card, after timeout seconds, the transaction will be timed out.

## Set Transaction Amount

The transaction amount can be set by:

```objc
	[pos setAmount:amount aAmountDescribe:cashbackAmount currency:currencyCode transactionType:TransactionType_GOODS];
```

the setAmount method can be called before start a transaction. If it was not called, a call back will be invoked by the SDK, giving app another chance to enter the transaction amount.

```objc
	-(void) onRequestSetAmount{
    		[pos setAmount:amount aAmountDescribe:cashbackAmount currency:currencyCode transactionType:TransactionType_GOODS];
	}
```

The setAmount method has below parameters: 
1. amount : how much money in cents
2. cashbackAmount : reserved for future use 
3. currency code : US Dollar,  CNY, etc
4. transactionType : which kind of transaction to be started. The transaction type can be:

```objc
	typedef NS_ENUM(NSInteger, TransactionType) {
    		TransactionType_GOODS, 
    		TransactionType_SERVICES,
    		TransactionType_CASH,
    		TransactionType_CASHBACK,
    		TransactionType_INQUIRY,
    		TransactionType_TRANSFER,
    		TransactionType_ADMIN,
    		TransactionType_CASHDEPOSIT,
    		TransactionType_PAYMENT,
    		TransactionType_PBOCLOG,
    		TransactionType_SALE,
    		TransactionType_PREAUTH,
    		TransactionType_ECQ_DESIGNATED_LOAD,
    		TransactionType_ECQ_UNDESIGNATED_LOAD,
    		TransactionType_ECQ_CASH_LOAD,
    		TransactionType_ECQ_CASH_LOAD_VOID,
    		TransactionType_ECQ_INQUIRE_LOG,
    		TransactionType_REFUND,
    		TransactionType_UPDATE_PIN
	};
```
Transaction type is used mainly by the EMV Chip card transaction, for magnetic card, app can always use GOODS.

## Magstripe Card Transaction

Magstripe card transaction is pretty simple. 
After the app start a transaction, if the user use a magnatic card, below callback will be called feeding the app magnatic card related information. The app then use the information returned for further processing.

```objc
	-(void) onDoTradeResult: (DoTradeResult)result DecodeData:(NSDictionary*)decodeData{
		if (result == DoTradeResult_NONE) {
			self.textViewLog.text = @"No card detected. Please insert or swipe card again and press check card.";
			[pos doTrade:30];
		}else if (result==DoTradeResult_ICC) {
			self.textViewLog.text = @"ICC Card Inserted";
			//Use this API to activate chip card transactions
			[pos doEmvApp:EmvOption_START];
		}else if(result==DoTradeResult_NOT_ICC){
			self.textViewLog.text = @"Card Inserted (Not ICC)";
		}else if(result==DoTradeResult_MCR){
			NSString *formatID = [NSString stringWithFormat:@"Format ID: %@\n",decodeData[@"formatID"]] ;
			NSString *maskedPAN = [NSString stringWithFormat:@"Masked PAN: %@\n",decodeData[@"maskedPAN"]];
			NSString *expiryDate = [NSString stringWithFormat:@"Expiry Date: %@\n",decodeData[@"expiryDate"]];
			NSString *cardHolderName = [NSString stringWithFormat:@"Cardholder Name: %@\n",decodeData[@"cardholderName"]];
			NSString *serviceCode = [NSString stringWithFormat:@"Service Code: %@\n",decodeData[@"serviceCode"]];
			NSString *encTrack1 = [NSString stringWithFormat:@"Encrypted Track 1: %@\n",decodeData[@"encTrack1"]];
			NSString *encTrack2 = [NSString stringWithFormat:@"Encrypted Track 2: %@\n",decodeData[@"encTrack2"]];
			NSString *encTrack3 = [NSString stringWithFormat:@"Encrypted Track 3: %@\n",decodeData[@"encTrack3"]];
			NSString *pinKsn = [NSString stringWithFormat:@"PIN KSN: %@\n",decodeData[@"pinKsn"]];
			NSString *trackksn = [NSString stringWithFormat:@"Track KSN: %@\n",decodeData[@"trackksn"]];
			NSString *pinBlock = [NSString stringWithFormat:@"pinBlock: %@\n",decodeData[@"pinblock"]];
			NSString *encPAN = [NSString stringWithFormat:@"encPAN: %@\n",decodeData[@"encPAN"]];
			NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Card Swiped:\n", nil)];
			NSString *a = [QPOSUtil byteArray2Hex:[QPOSUtil stringFormatTAscii:maskedPAN]];
			[pos getPin:1 keyIndex:0 maxLen:6 typeFace:@"Pls Input Pin" cardNo:a data:@"" delay:30 withResultBlock:^(BOOL isSuccess, NSDictionary *result) {
				self.textViewLog.backgroundColor = [UIColor greenColor];
				[self playAudio];
				AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
				self.textViewLog.text = msg;
				self.lableAmount.text = @"";
			}];
		}else if(result==DoTradeResult_NFC_OFFLINE || result == DoTradeResult_NFC_ONLINE){
			NSString *formatID = [NSString stringWithFormat:@"Format ID: %@\n",decodeData[@"formatID"]] ;
			NSString *maskedPAN = [NSString stringWithFormat:@"Masked PAN: %@\n",decodeData[@"maskedPAN"]];
			NSString *expiryDate = [NSString stringWithFormat:@"Expiry Date: %@\n",decodeData[@"expiryDate"]];
			NSString *cardHolderName = [NSString stringWithFormat:@"Cardholder Name: %@\n",decodeData[@"cardholderName"]];
			NSString *serviceCode = [NSString stringWithFormat:@"Service Code: %@\n",decodeData[@"serviceCode"]];
			NSString *encTrack1 = [NSString stringWithFormat:@"Encrypted Track 1: %@\n",decodeData[@"encTrack1"]];
			NSString *encTrack2 = [NSString stringWithFormat:@"Encrypted Track 2: %@\n",decodeData[@"encTrack2"]];
			NSString *encTrack3 = [NSString stringWithFormat:@"Encrypted Track 3: %@\n",decodeData[@"encTrack3"]];
			NSString *pinKsn = [NSString stringWithFormat:@"PIN KSN: %@\n",decodeData[@"pinKsn"]];
			NSString *trackksn = [NSString stringWithFormat:@"Track KSN: %@\n",decodeData[@"trackksn"]];
			NSString *pinBlock = [NSString stringWithFormat:@"pinBlock: %@\n",decodeData[@"pinblock"]];
			NSString *encPAN = [NSString stringWithFormat:@"encPAN: %@\n",decodeData[@"encPAN"]];
			NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Tap Card:\n", nil)];
			dispatch_async(dispatch_get_main_queue(),  ^{
				NSDictionary *mDic = [pos getNFCBatchData];
				NSString *tlv;
				if(mDic !=nil){
					tlv= [NSString stringWithFormat:@"NFCBatchData: %@\n",mDic[@"tlv"]];
					NSLog(@"--------nfc:tlv%@",tlv);
				}else{
					tlv = @"";
				}
				self.textViewLog.backgroundColor = [UIColor greenColor];
				[self playAudio];
				AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
				self.textViewLog.text = [msg stringByAppendingString:tlv];
				self.lableAmount.text = @"";
			});
		}else if(result==DoTradeResult_NFC_DECLINED){
			self.textViewLog.text = @"Tap Card Declined";
		}else if (result==DoTradeResult_NO_RESPONSE){
			self.textViewLog.text = @"Check card no response";
		}else if(result==DoTradeResult_BAD_SWIPE){
			self.textViewLog.text = @"Bad Swipe. \nPlease swipe again and press check card.";
		}else if(result==DoTradeResult_NO_UPDATE_WORK_KEY){
			self.textViewLog.text = @"device not update work key";
		}else if(result==DoTradeResult_CARD_NOT_SUPPORT){
			self.textViewLog.text = @"card not support";
		}else if(result==DoTradeResult_PLS_SEE_PHONE){
			self.textViewLog.text = @"pls see phone";
		}else if(result==DoTradeResult_TRY_ANOTHER_INTERFACE){
			self.textViewLog.text = @"pls try another interface";
		}
     }
```

Below table describes the meaning of each data element SDK returned:

Key         | Description
------------|------------------
maskedPAN	| Masked card number showing at most the first 6 and last 4 digits with in-between digits masked by “X”
expiryDate	| 4-digit in the form of YYMM in the track data
cardHolderName|	The cardholder name as seen on the card. This can be up to 26 characters.
serviceCode	  | 3-digit service code in the track data
track1Length  |	Length of Track 1 data
track2Length  |	Length of Track 2 data
track3Length  |	Length of Track 3 data
encTracks	  | Reserved
encTrack1	  | Encrypted track 1 data with T-Des encryption key derived from DATA-key to be generated with trackksn and IPEK
encTrack2	  | Encrypted track 2 data with T-Des encryption key derived from DATA-key to be generated with trackksn and IPEK
encTrack3	  | Encrypted track 3 data with T-Des encryption key derived from DATA-key to be generated with trackksn and IPEK 
partialTrack  |	Reserved
trackksn	  | KSN of the track data

The track data returned in the hashtable is encrytped. It can be encrypted by Dukpt Data Key Variant 3DES ECB mode, or by Dukpt Data Key 3DES CBC mode. Per ANSI X9.24 2009 version request, The later (Data Key with 3DES CBC mode) is usually a recommanded choice.

### Decoding Track Data Encrypted with Data Key Variant

Below is an example of the data captured during a live magnatic transaction, the track data is encrypted using data key variant, in 3DES ECB mode:

```
01-20 06:58:29.412: D/POS_SDK(3609): decodeData: {track3Length=0, track2Length=32, expiryDate=1011, encTrack3=, encPAN=, encTrack1=744B8A95FF1982CD63FB24D581FCD1A0590E7F6DD12B86ED1B1D26E687EA853A128598C16BE14964A34607452511C4B6CBDCACD72BEB566E32094937C18C2424, pinRandomNumber=, encTrack2=5E7E2D56D3496B2721EBD4C590031EB9D7883B75B97A71FF, trackRandomNumber=, trackksn=00000332100300E0000A, maskedPAN=622526XXXXXX5453, cardholderName=MR.ZHOU CHENG HAO         , partialTrack=, encTracks=5E7E2D56D3496B2721EBD4C590031EB9D7883B75B97A71FF, psamNo=, formatID=30, track1Length=68, pinKsn=, serviceCode=106, ksn=, pinBlock=}
01-20 06:58:29.413: D/POS_SDK(3609): swipe card:Card Swiped:Format ID: 30
01-20 06:58:29.413: D/POS_SDK(3609): Masked PAN: 622526XXXXXX5453
01-20 06:58:29.413: D/POS_SDK(3609): Expiry Date: 1011
01-20 06:58:29.413: D/POS_SDK(3609): Cardholder Name: MR.ZHOU CHENG HAO         
01-20 06:58:29.413: D/POS_SDK(3609): KSN: 
01-20 06:58:29.413: D/POS_SDK(3609): pinKsn: 
01-20 06:58:29.413: D/POS_SDK(3609): trackksn: 00000332100300E0000A
01-20 06:58:29.413: D/POS_SDK(3609): Service Code: 106
01-20 06:58:29.413: D/POS_SDK(3609): Track 1 Length: 68
01-20 06:58:29.413: D/POS_SDK(3609): Track 2 Length: 32
01-20 06:58:29.413: D/POS_SDK(3609): Track 3 Length: 0
01-20 06:58:29.413: D/POS_SDK(3609): Encrypted Tracks: 5E7E2D56D3496B2721EBD4C590031EB9D7883B75B97A71FF
01-20 06:58:29.413: D/POS_SDK(3609): Encrypted Track 1: 744B8A95FF1982CD63FB24D581FCD1A0590E7F6DD12B86ED1B1D26E687EA853A128598C16BE14964A34607452511C4B6CBDCACD72BEB566E32094937C18C2424
01-20 06:58:29.413: D/POS_SDK(3609): Encrypted Track 2: 5E7E2D56D3496B2721EBD4C590031EB9D7883B75B97A71FF
01-20 06:58:29.413: D/POS_SDK(3609): Encrypted Track 3: 
01-20 06:58:29.413: D/POS_SDK(3609): Partial Track: 
01-20 06:58:29.413: D/POS_SDK(3609): pinBlock: 
01-20 06:58:29.413: D/POS_SDK(3609): encPAN: 
01-20 06:58:29.413: D/POS_SDK(3609): trackRandomNumber: 
01-20 06:58:29.413: D/POS_SDK(3609): pinRandomNumber: 
```

The track ksn 00000332100300E0000A can be used to decode the track data:

Track 1 data:
744B8A95FF1982CD63FB24D581FCD1A0590E7F6DD12B86ED1B1D26E687EA853A128598C16BE14964A34607452511C4B6CBDCACD72BEB566E32094937C18C2424

Track 2 data:
5E7E2D56D3496B2721EBD4C590031EB9D7883B75B97A71FF

Below python script demostrate how to decode track data encrypted with DataKey Variant in ECB mode:
```python
def GetDataKeyVariant(ksn, ipek):
    key = GetDUKPTKey(ksn, ipek)
    key = bytearray(key)
    key[5] ^= 0xFF
    key[13] ^= 0xFF
    return str(key)

def TDES_Dec(data, key):
    t = triple_des(key, ECB, padmode=None)
    res = t.decrypt(data)
    return res

def decrypt_card_info(ksn, data):
    BDK = unhexlify("0123456789ABCDEFFEDCBA9876543210")
    ksn = unhexlify(ksn)
    data = unhexlify(data)
    IPEK = GenerateIPEK(ksn, BDK)
    DATA_KEY_VAR = GetDataKeyVariant(ksn, IPEK)
    print hexlify(DATA_KEY_VAR)
    res = TDES_Dec(data, DATA_KEY_VAR)
    return hexlify(res)
```


Using data key variant to decrypt track 1, will get:

```
16259249 54964104 16598554 553FADC8 EEA8BF50 23A25BA7 02886F00 00000000 0003E450 45145059 15D44964 10653590 41041041 F0000000 00000000 00000000
```
Each character in Track 1 is 6 bits in length, 4 characters are packed into 3 bytes. Each character is mapped from 0x20 to 0x5F. So to get the real ASCII value of each charactor, you need to add 0x20 to each decoded 6 bits.

```
For example, the leading 3 bytes of above track 1 data is 16,25,92

Which in binary is: 00010110 00100101 10010010
Unpacked them to 4 bytes: 000101 100010 010110 010010
Which in binary is:05221612
Add 0x20 to each byte:25423632
Which is in ASCII :%B62
```

Using data key variant to decrypt track 2, will get:
```
62252600 06685453 D1011106 17426936 FFFFFFFF FFFFFFFF 
```

Each character in Track 2 & Track 3 is 4 bits in length. 2 characters are packed into 1 byte and padded with zero before encryption

### Decoding Track Data Encrypted with Data Key

Below is another example, the track data is encrypted using data key whith 3DES CBC mode (per ANSI X9.24 2009 version request)

```
01-21 04:46:26.764: D/POS_SDK(30241): decodeData: {track3Length=0, track2Length=32, expiryDate=1011, encTrack3=, encPAN=, encTrack1=22FB2E931F3EFAFC8C3899AB779F3719E75D392365DB748EEA789560EEB7714D84AB7FFA5B2E162C9BD566D03DCD240FC9D316CAC4015B782294365F9062CA0A, pinRandomNumber=, encTrack2=153CEE49576C0B709515946D991CB48368FEA0375837ECA6, trackRandomNumber=, trackksn=00000332100300E00002, maskedPAN=622526XXXXXX5453, cardholderName=MR.ZHOU CHENG HAO         , partialTrack=, encTracks=153CEE49576C0B709515946D991CB48368FEA0375837ECA6, psamNo=, formatID=30, track1Length=68, pinKsn=, serviceCode=106, ksn=, pinBlock=}
01-21 04:46:26.766: D/POS_SDK(30241): swipe card:Card Swiped:Format ID: 30
01-21 04:46:26.766: D/POS_SDK(30241): Masked PAN: 622526XXXXXX5453
01-21 04:46:26.766: D/POS_SDK(30241): Expiry Date: 1011
01-21 04:46:26.766: D/POS_SDK(30241): Cardholder Name: MR.ZHOU CHENG HAO         
01-21 04:46:26.766: D/POS_SDK(30241): KSN: 
01-21 04:46:26.766: D/POS_SDK(30241): pinKsn: 
01-21 04:46:26.766: D/POS_SDK(30241): trackksn: 00000332100300E00002
01-21 04:46:26.766: D/POS_SDK(30241): Service Code: 106
01-21 04:46:26.766: D/POS_SDK(30241): Track 1 Length: 68
01-21 04:46:26.766: D/POS_SDK(30241): Track 2 Length: 32
01-21 04:46:26.766: D/POS_SDK(30241): Track 3 Length: 0
01-21 04:46:26.766: D/POS_SDK(30241): Encrypted Tracks: 153CEE49576C0B709515946D991CB48368FEA0375837ECA6
01-21 04:46:26.766: D/POS_SDK(30241): Encrypted Track 1: 22FB2E931F3EFAFC8C3899AB779F3719E75D392365DB748EEA789560EEB7714D84AB7FFA5B2E162C9BD566D03DCD240FC9D316CAC4015B782294365F9062CA0A
01-21 04:46:26.766: D/POS_SDK(30241): Encrypted Track 2: 153CEE49576C0B709515946D991CB48368FEA0375837ECA6
01-21 04:46:26.766: D/POS_SDK(30241): Encrypted Track 3: 
01-21 04:46:26.766: D/POS_SDK(30241): Partial Track: 
01-21 04:46:26.766: D/POS_SDK(30241): pinBlock: 
01-21 04:46:26.766: D/POS_SDK(30241): encPAN: 
01-21 04:46:26.766: D/POS_SDK(30241): trackRandomNumber: 
01-21 04:46:26.766: D/POS_SDK(30241): pinRandomNumber: 
```

Below python script demostrate how to decode track data encrypted with DataKey in CBC mode:

```python
def GetDataKeyVariant(ksn, ipek):
    key = GetDUKPTKey(ksn, ipek)
    key = bytearray(key)
    key[5] ^= 0xFF
    key[13] ^= 0xFF
    return str(key) 

def GetDataKey(ksn, ipek):
    key = GetDataKeyVariant(ksn, ipek)
    return str(TDES_Enc(key,key))

def TDES_Dec(data, key):
    t = triple_des(key, CBC, "\0\0\0\0\0\0\0\0",padmode=None)
    res = t.decrypt(data)
    return res

def decrypt_card_info(ksn, data):
    BDK = unhexlify("0123456789ABCDEFFEDCBA9876543210")
    ksn = unhexlify(ksn)
    data = unhexlify(data)
    IPEK = GenerateIPEK(ksn, BDK)
    DATA_KEY = GetDataKey(ksn, IPEK)
    print hexlify(DATA_KEY)
    res = TDES_Dec(data, DATA_KEY)
    return hexlify(res)

```
The decoded track 1 and track 2 data are the same as the track data we got in previous section.

## Decoding PIN 

The QPOS will also send the encryted PIN to the mobile application:
```
10-07 11:37:49.571: V/vahid(20753): ???? ????? ??:Format ID: 30
10-07 11:37:49.571: V/vahid(20753): Masked PAN: 622106XXXXXX1111
10-07 11:37:49.571: V/vahid(20753): Expiry Date: 1605
10-07 11:37:49.571: V/vahid(20753): Cardholder Name:
10-07 11:37:49.571: V/vahid(20753): KSN:
10-07 11:37:49.571: V/vahid(20753): pinKsn: 00000332100300E000E6
10-07 11:37:49.571: V/vahid(20753): trackksn: 00000332100300E000C6
10-07 11:37:49.571: V/vahid(20753): Service Code: 100
10-07 11:37:49.571: V/vahid(20753): Track 1 Length: 0
10-07 11:37:49.571: V/vahid(20753): Track 2 Length: 37
10-07 11:37:49.571: V/vahid(20753): Track 3 Length: 37
10-07 11:37:49.571: V/vahid(20753): Encrypted Tracks: 47B35616888BB17A055BE87FBAC76DCDD3EFFACA5F1C901047B35616888BB17A055BE87FBAC76DCDD3EFFACA5F1C901060325F039768CE5760325F039768CE5760325F039768CE5760325F039768CE57
10-07 11:37:49.571: V/vahid(20753): Encrypted Track 1:
10-07 11:37:49.571: V/vahid(20753): Encrypted Track 2: 47B35616888BB17A055BE87FBAC76DCDD3EFFACA5F1C9010
10-07 11:37:49.571: V/vahid(20753): Encrypted Track 3: 47B35616888BB17A055BE87FBAC76DCDD3EFFACA5F1C901060325F039768CE5760325F039768CE5760325F039768CE5760325F039768CE57
10-07 11:37:49.571: V/vahid(20753): Partial Track:
10-07 11:37:49.571: V/vahid(20753): pinBlock: 377D28B8C7EF080A
10-07 11:37:49.571: V/vahid(20753): encPAN:
10-07 11:37:49.571: V/vahid(20753): trackRandomNumber:
10-07 11:37:49.571: V/vahid(20753): pinRandomNumber:
```

Decode the Track 2 data using the method descripted before: 
6221061055111111D16051007832281716058FFFFFFFFFFF

Below python script demostrate how to decode PINBLOCK:

```python
def GetPINKeyVariant(ksn, ipek):
    key = GetDUKPTKey(ksn, ipek)
    key = bytearray(key)
    key[7] ^= 0xFF
    key[15] ^= 0xFF
    return str(key)

def TDES_Dec(data, key):
    t = triple_des(key, ECB, padmode=None)
    res = t.decrypt(data)
    return res

def decrypt_pinblock(ksn, data):
    BDK = unhexlify("0123456789ABCDEFFEDCBA9876543210")
    ksn = unhexlify(ksn)
    data = unhexlify(data)
    IPEK = GenerateIPEK(ksn, BDK)
    PIN_KEY = GetPINKeyVariant(ksn, IPEK)
    print hexlify(PIN_KEY)
    res = TDES_Dec(data, PIN_KEY)
    return hexlify(res)

if __name__ == "__main__":
    KSN = "00000332100300E000E6"
    DATA = "377D28B8C7EF080A"
    #DATA="153CEE49576C0B709515946D991CB48368FEA0375837ECA6"
    print decrypt_pinblock(KSN, DATA)

```

The decrypted PINBLOCK (formated Pin data) is: 0411019efaaeeeee
The real PIN value can be caculated using formated pin data and PAN as inputs, according to ANSI X9.8. Below is an example:

1) PAN: 6221061055111111
2) 12 right most PAN digits without checksum: 106105511111
3) Add 0000 to the left: 0000106105511111
4) XOR (#3) and Formated PIN Data 

XOR (0000106105511111, 0411019efaaeeeee) = 041111FFFFFFFFFF
In our example, the plain PIN is 4 bytes in length with data "1111"


## Chip Card Transaction

EMV Chip card transaction is much more complicate than magnatic swipe card transaction. The EMV kernel inside the device may need a lot of information to process the transaction, including:

1. PIN from the card holder
2. Current time from the application
3. Preferred EMV application from card holder
4. The process result from the bank (card issuer) for the transaction

### Start Chip Card Transaction

The app start the EMV transaction by calling
```objc
	[pos doEmvApp:EmvOption_START];
```
This is usually happens inside the call back of onDoTradeResult(), as below demo code shows:

```objc
	-(void) onDoTradeResult: (DoTradeResult)result DecodeData:(NSDictionary*)decodeData{
		if (result == DoTradeResult_NONE) {
			self.textViewLog.text = @"No card detected. Please insert or swipe card again and press check card.";
			[pos doTrade:30];
		}else if (result==DoTradeResult_ICC) {
			self.textViewLog.text = @"ICC Card Inserted";
			[pos doEmvApp:EmvOption_START];
		}else if(result==DoTradeResult_NOT_ICC){
			self.textViewLog.text = @"Card Inserted (Not ICC)";
		}else if(result==DoTradeResult_MCR){
			self.textViewLog.text = @"MSR";
		}else if(result==DoTradeResult_NFC_OFFLINE || result == DoTradeResult_NFC_ONLINE){
			self.textViewLog.text = @"NFC";
		}else if(result==DoTradeResult_NFC_DECLINED){
			self.textViewLog.text = @"Tap Card Declined";
		}else if (result==DoTradeResult_NO_RESPONSE){
			self.textViewLog.text = @"Check card no response";
		}else if(result==DoTradeResult_BAD_SWIPE){
			self.textViewLog.text = @"Bad Swipe. \nPlease swipe again and press check card.";
		}else if(result==DoTradeResult_NO_UPDATE_WORK_KEY){
			self.textViewLog.text = @"device not update work key";
		}else if(result==DoTradeResult_CARD_NOT_SUPPORT){
			self.textViewLog.text = @"card not support";
		}else if(result==DoTradeResult_PLS_SEE_PHONE){
			self.textViewLog.text = @"pls see phone";
		}else if(result==DoTradeResult_TRY_ANOTHER_INTERFACE){
			self.textViewLog.text = @"pls try another interface";
		}
	}
```

### Input PIN 

The PIN information can be sent to the EMV kernel by:
```objc
	-(void) onRequestPinEntry{
		[pos sendPinEntryResult:pinStr];
	}
```
Note, the kernel will not call the callback if PIN is not required for the transaction, or if the QPOS itself is with an embedded PINPAD.

If the user do not want to input PIN, the applicaiton can bypass PIN enter by calling 

```objc
	[pos bypassPinEntry];
```
if the user want to cancel the transaction, the app should call
```objc
	[pos cancelPinEntry];
```

### Set Time

The current time information can be sent to the EMV kernel by:

```objc
	-(void) onRequestTime{
		NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
		NSRange containA = [formatStringForHours rangeOfString:@"a"];
		BOOL hasAMPM = containA.location != NSNotFound;
		//when phone time is 12h format, need add this judgement.
		if (hasAMPM) {
			NSDateFormatter *dateFormatter = [NSDateFormatter new];
			[dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
			terminalTime = [dateFormatter stringFromDate:[NSDate date]];
		}else{
			NSDateFormatter *dateFormatter = [NSDateFormatter new];
			[dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
			_terminalTime = [dateFormatter stringFromDate:[NSDate date]];
		}
		[pos sendTime:_terminalTime];
	}
```

### Select EMV Application

If there is multiple EMV applications inside one Chip card, the SDK will ask the user to choose one application from a list:
```objc
	-(void) onRequestSelectEmvApp: (NSArray*)appList{
   
	}
```

The chosen application is sending to the EMV kernel by 
```objc
	[pos selectEmvApp:buttonIndex];
```

If the user want to cancel select application, app should call 
```objc
	[pos cancelSelectEmvApp];
```

### Online Request

If the EMV kernel found the transaction need to go online, below call back will be called.
```objc
	-(void) onRequestOnlineProcess: (NSString*) tlv{
		//sending online message tlv data to issuer
		....
		//send the received online processing result to POS
		[pos sendOnlineProcessResult(@"8A023030")];
	}
```

Below is an exmple of tlv data received by onRequestOnlineProcess:
```
2014-08-27 17:52:21.210 qpos-ios-demo[391:60b] alertView.title = Online process requested.
2014-08-27 17:52:21.211 qpos-ios-demo[391:60b] hideAlertView
2014-08-27 17:52:21.221 qpos-ios-demo[391:60b] onRequestOnlineProcess = {
    tlv = 5F200220204F08A0000003330101015F24032312319F160F4243544553542031323334353637389F21031752139A031408279F02060000000000019F03060000000000009F34034203009F120A50424F43204445424954C409623061FFFFFFFF5284C10A00000332100300E00003C708A68701E68CB34BDEC00A00000332100300E00003C2820150E84B5D0D2AA9F40A2EFCC52424C52DDE2ABB1A07F8B53A8F37837A9AA4BF7200CC55AA1480ED5665AEC03DFE493248AEEA126345F1C2BA0EB0AA82546CC0AF5E6F4E40D7F9A3788C8F35B33F5AF1D85231D77FCE112A1C9D2AFF3679C3C46456232D32FD0D2AAF288CFD4CC52C1F33F128C247296C9E46647D930ACED5B34CFD0C2A823B3F91BEC60E8280005CB96C3EFCCC352F0A30F77A2A033361B5C2C720D8B6E85BFA3C589ADBD6FAF15D3C520085A5276B736860441BB15DBF8FA537708654EE90E32C194D1487362498F59346706FD797DFC8DD28FCF31E7D49886BA62779EC42411A54F03FE22B9431969B780E8280005CB96C3EEF460C1F76C0F2217EAC9B999E3E03128A93A11A4FC6885E4106A4EA4D815D10900AC6AC95E3325D585CB8678AE17A4DEE4C45E2E44209B9493B5FD94F3F46CCF730CD8FED9430B7574CE670018A94907B2AA4B475A93ABF;
}
```

The tlv data can be decoded using the online EMVlab tool:

http://www.emvlab.org/tlvutils/?data=5F200220204F08A0000003330101015F24032312319F160F4243544553542031323334353637389F21031752139A031408279F02060000000000019F03060000000000009F34034203009F120A50424F43204445424954C409623061FFFFFFFF5284C10A00000332100300E00003C708A68701E68CB34BDEC00A00000332100300E00003C2820150E84B5D0D2AA9F40A2EFCC52424C52DDE2ABB1A07F8B53A8F37837A9AA4BF7200CC55AA1480ED5665AEC03DFE493248AEEA126345F1C2BA0EB0AA82546CC0AF5E6F4E40D7F9A3788C8F35B33F5AF1D85231D77FCE112A1C9D2AFF3679C3C46456232D32FD0D2AAF288CFD4CC52C1F33F128C247296C9E46647D930ACED5B34CFD0C2A823B3F91BEC60E8280005CB96C3EFCCC352F0A30F77A2A033361B5C2C720D8B6E85BFA3C589ADBD6FAF15D3C520085A5276B736860441BB15DBF8FA537708654EE90E32C194D1487362498F59346706FD797DFC8DD28FCF31E7D49886BA62779EC42411A54F03FE22B9431969B780E8280005CB96C3EEF460C1F76C0F2217EAC9B999E3E03128A93A11A4FC6885E4106A4EA4D815D10900AC6AC95E3325D585CB8678AE17A4DEE4C45E2E44209B9493B5FD94F3F46CCF730CD8FED9430B7574CE670018A94907B2AA4B475A93ABF%0D%0A

As we can see from the decoded table:

Tag  | Tag Name            | Value
-----|---------------------|------
5F20 | Cardholder Name     |
4F   | AID                 | A000000333010101
5F24 | App Expiration Date | 231231
9F16 | Merchant ID         | B C T E S T 1 2 3 4 5 6 7 8
9F21 | Transaction Time    | 175213
...  | ...                 | ...
C4   | Masked PAN          | 623061FFFFFFFF5284
C1   | KSN(PIN)            | 00000332100300E00003
C7   | PINBLOCK            | A68701E68CB34BDE
C0   | KSN Online Msg      | 00000332100300E00003
C2   | Online Message      | E84B5D0D2AA9F40A2EFC....

Inside the table, there are:
1. Some EMV TAGs (5F20,4F,5F24 ...) with plain text value. 
2. Some Proprietary tags starting with 0xC, in our case C4,C1,C7,C0 and C2.

The defination of proprietary tags can be found below:

Tag   | Name                      | Length(Bytes)
------|---------------------------|--------------
C0    | KSN of Online Msg         | 10
C1    | KSN of PIN                | 10
C2    | Online Message(E)         | var
C3    | KSN of Batch/Reversal Data| 10
C4    | Masked PAN                | 0~10
C5    | Batch Data                | var
C6    | Reversal Data             | var
C7    | PINBLOCK                  | 8

It's the responsibility of the app to handle the online message string, sending them to the bank( the cardd issuer), and check the bank processing result.

The value of tag C2 is the encrypted Online Message, usually the app need to send it to the back end system, along with the tag C0 value. The backend system can derive the 3DES key from C0 value, and decrypt the C2 value and get the real online data in plain text format.

In case encrypted PIN is needed by the transaction, the app can also send the value of tag C7,C1 to back end system.

The example above is just a demostration. "8A023030" is a fake result from back end system.

As an exmple of decoding the online message, please find below some demo scripts:

```python

def decrypt_icc_info(ksn, data):
    BDK = unhexlify("0123456789ABCDEFFEDCBA9876543210")
    ksn = unhexlify(ksn)
    data = unhexlify(data)
    IPEK = GenerateIPEK(ksn, BDK)
    DATA_KEY = GetDataKey(ksn, IPEK)
    print hexlify(DATA_KEY)
    res = TDES_Dec(data, DATA_KEY)
    return hexlify(res)

if __name__ == "__main__":
    KSN = "00000332100300E00003"
    DATA = "E84B5D0D2AA9F40A2EFCC52424C52DDE2ABB1A07F8B53A8F37837A9AA4BF7200CC55AA1480ED5665AEC03DFE493248AEEA126345F1C2BA0EB0AA82546CC0AF5E6F4E40D7F9A3788C8F35B33F5AF1D85231D77FCE112A1C9D2AFF3679C3C46456232D32FD0D2AAF288CFD4CC52C1F33F128C247296C9E46647D930ACED5B34CFD0C2A823B3F91BEC60E8280005CB96C3EFCCC352F0A30F77A2A033361B5C2C720D8B6E85BFA3C589ADBD6FAF15D3C520085A5276B736860441BB15DBF8FA537708654EE90E32C194D1487362498F59346706FD797DFC8DD28FCF31E7D49886BA62779EC42411A54F03FE22B9431969B780E8280005CB96C3EEF460C1F76C0F2217EAC9B999E3E03128A93A11A4FC6885E4106A4EA4D815D10900AC6AC95E3325D585CB8678AE17A4DEE4C45E2E44209B9493B5FD94F3F46CCF730CD8FED9430B7574CE670018A94907B2AA4B475A93ABF"
    print decrypt_icc_info(KSN, DATA)

```

The decoded icc online message looks like:

http://www.emvlab.org/tlvutils/?data=708201479f02060000000000015a096230615710101752845713623061571010175284d231222086038214069f9f101307010103a02000010a01000000000013f6c0429f160f4243544553542031323334353637389f4e0f61626364000000000000000000000082027c008e0e000000000000000042031e031f005f24032312315f25031307304f08a0000003330101019f0702ff009f0d05d8609ca8009f0e0500100000009f0f05d8689cf8009f2608059aae950d0b7a679f2701809f3602008d9c01009f3303e0f8c89f34034203009f3704c1cdd24a9f3901059f4005f000f0a0019505088004e0009b02e8008408a0000003330101019a031408275f2a0201565f3401019f03060000000000009f0902008c9f1a0206439f1e0838333230314943439f3501229f4104000000015f200220205f300202205f28020156500a50424f432044454249540000000000

All the online message in embedded inside tag 0x70, the ending 00 are paddings for 3DES encryption.

### Get Transaction Result 

The application will be notified by the SDK regarding the transaction result by:

```objc
	-(void) onRequestTransactionResult: (TransactionResult)transactionResult{
		if (transactionResult == TransactionResult.APPROVED) {
		} else if (transactionResult == TransactionResult.TERMINATED) {
		} else if (transactionResult == TransactionResult.DECLINED) {
		} else if (transactionResult == TransactionResult.CANCEL) {
		} else if (transactionResult == TransactionResult.CAPK_FAIL) {
		} else if (transactionResult == TransactionResult.NOT_ICC) {
		} else if (transactionResult == TransactionResult.SELECT_APP_FAIL) {
		} else if (transactionResult == TransactionResult.DEVICE_ERROR) {
		} else if (transactionResult == TransactionResult.CARD_NOT_SUPPORTED) {
		} else if (transactionResult == TransactionResult.MISSING_MANDATORY_DATA) {
		} else if (transactionResult == TransactionResult.CARD_BLOCKED_OR_NO_EMV_APPS) {
		} else if (transactionResult == TransactionResult.INVALID_ICC_DATA) {
		} else if(transactionResult == TransactionResult_CARD_BLOCKED) {
		} else if(transactionResult == TransactionResult_APP_BLOCKED) {;
		} else if(transactionResult == TransactionResult_MULTIPLE_CARDS) {
		}      
    }
    
```

### Batch Data Handling

When the transaction is finished. The batch data will be returned to the application by below callback.

```objc
	-(void) onRequestBatchData: (NSString*)tlv
		...
	}
```
Note, if there is issuer's script result inside the tlv, the mobile app need to feedback it to the bank.
Decoding the tlv inside onRequestBatchData is similar to decoding onRequestOnlineProcess. 

### Reversal Handling

If the EMV chip card refuse the transaction, but the transaction was approved by the issuer. A reversal procedure should be initiated by the mobile app. The requred data for doing reversal can be got by below call back:

```objc
	-(void) onReturnReversalData: (NSString*)tlv{
		...
	}
```

## Error Notification

During the transaction, if there is anything abnormal happened, the onError callback will be called.

```objc
	-(void) onDHError: (DHError)errorState{
		if (errorState == Error.CMD_NOT_AVAILABLE) {
		} else if (errorState == Error.TIMEOUT) {
		} else if (errorState == Error.DEVICE_RESET) {
		} else if (errorState == Error.UNKNOWN) {
		} else if (errorState == Error.DEVICE_BUSY) {
		} else if (errorState == Error.INPUT_OUT_OF_RANGE) {
		} else if (errorState == Error.INPUT_INVALID_FORMAT) {
		} else if (errorState == Error.INPUT_ZERO_VALUES) {
		} else if (errorState == Error.INPUT_INVALID) {
		} else if (errorState == Error.CASHBACK_NOT_SUPPORTED) {
		} else if (errorState == Error.CRC_ERROR) {
		} else if (errorState == Error.COMM_ERROR) {
		} else if (errorState == Error.MAC_ERROR) {
		} else if (errorState == Error.CMD_TIMEOUT) {
		}
	}

```

