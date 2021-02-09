//
//  DocumentInsertView.h
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 20/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import "CameraMain.h"

// intra-dependencies
//#import "AFHTTPSessionManager.h"
//#import "AFNetworking.h"
//#import "AFHTTPSessionManager.h"
//#import "JGProgressHUD.h"

@class AcessoBioManager;


typedef NS_ENUM(NSInteger, OperationType) {
    Default,
    OCR,
    Facematch
};


NS_ASSUME_NONNULL_BEGIN

@interface DocumentInsertView : CameraMain {
  //  JGProgressHUD *HUD;
    UIButton *btClose;
}

@property (assign, nonatomic)NSInteger type; 
@property (strong, nonatomic) AcessoBioManager *acessoBioManager;

@property (strong, nonatomic) NSString *URL;
@property (strong, nonatomic) NSString *APIKEY;
@property (strong, nonatomic) NSString *TOKEN;

@property (assign, nonatomic) OperationType operationType;

@property (strong, nonatomic) NSString *base64SelfieToFaceMatch;

@end

NS_ASSUME_NONNULL_END
