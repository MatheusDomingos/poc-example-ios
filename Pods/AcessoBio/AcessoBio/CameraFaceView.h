//
//  CameraFaceView.h
//  CaptureAcesso
//
//  Created by Matheus Domingos on 10/05/20.
//  Copyright © 2020 Matheus  domingos. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import "UIImageUtils.h"

#import "CameraMain.h"

#import "UIViewWithHole.h"

#import <CoreML/CoreML.h>
#import <Vision/Vision.h>
#import "CenterModelCrop.h"

// gyroscope
#import <CoreMotion/CoreMotion.h>

#import "PopUpValidationLiveness.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

#import "AcessoBioManager.h"

@class CameraBio;

NS_ASSUME_NONNULL_BEGIN

@interface CameraFaceView : CameraMain <AVCaptureVideoDataOutputSampleBufferDelegate> {
    
    BOOL isSelfie;
    UIView *rectangle;
    UIView *rectangleTop;
    UIView *rectangleLeft;
    UIView *rectangleRight;
    UILabel *labelMessage;

    int countNoFace;
    int countTimeAlert;
    int countNoNose;

    BOOL isShowAlert;
        
    UIView *viewLog;
    UILabel *lbNosePosition;
    UILabel *lbRightEye;
    UILabel *lbLeftEye;
    UILabel *lbRightEar;
    UILabel *lbLeftEar;
    UILabel *lbEulerX;
    UILabel *lbSpaceEye;
    
    NSTimer * timerCountDown;
    NSInteger countDown;
    BOOL isCountDown;
        
#pragma mark - GLOBAL Liveness
    //Step Liveness - Discrimina o passo atual do liveness
    BOOL isShowAlertLiveness;
    BOOL isShowAlertToLiveness;
    BOOL isLivenessComplete;
    NSDictionary *dictLivenessResultCenter;
    NSDictionary *dictLivenessResultAway;
    NSDictionary *dictLivenessResultCloser;
    NSMutableArray *arrLeftEyeOpenProbability;

    float fTotal;
    
    UIViewWithHole *vHole;
    
    UIImageView *ivAcessoBio;
    
    
    CGRect frameCurrent;

    CGRect frameFaceCenter;
    CGRect frameFaceAway;
    CGRect frameFaceCloser;
    
    BOOL isSuccessAnimated;
    BOOL isErrorAnimated;
    
    BOOL isProccessIA;

    UILabel *lbMessage;
    UIView *vAlert;
    UIButton *btClose;
    
    BOOL isSmillingUpponEnter;
    
    BOOL isVerifiedSmillingUpponEnter;
    
    int delayToVerifySmilling;

    BOOL isResetRunning;
    BOOL isResetSessionValidate;
    int attemptsValidate;
    
    BOOL isResetSessionSpoofing;
        
    int attemptsSpoofing;

    BOOL isResetSessionNoComputated;
    
    UILabel *lbTitleAlertCustom;
    UIView *viewAlertBlack;
    
    NSTimer *timerProcesss;
    
    NSTimer *timerToTakeCenterPhoto;
    NSTimer *timerToTakeAwayPhoto;
    NSTimer *timerToSmiling;

    int durationProcess;
    BOOL isFastProcess;
    
    BOOL isDoneValidate;
    
    BOOL isStartProcessIA;
    
    int timeToTakeCenterPhoto;
    int timeToTakeAwayPhoto;
    int timeToSmiling;
    
    // Discrimino se é para fazer a captura da foto afastada sem o sorriso (que dificulta a captura).
    BOOL isPhotoAwayToCapture;
    
    UIImageView *ivBackgroundGreen;
    
    NSString *AuthToken;
    
    
    double scoreFacedetect;
    
    UIView *vFlash;
    UIActivityIndicatorView *spinFlash;
    
    int  userBlinks;
    
    
    int resultFaceDetectBehavior; // 1 = Face Match / 2 = Both substandard / 3 = Not match
    int resultFaceDetect; // // 1 = Face Match / 2 = Both substandard / 3 = Not match

    NSString *base64ToUsage;

    BOOL facesNoMatchInFaceDetect;

    BOOL isValidating;
    
    int SESSION;

    int TimeSessionFirst;
    int TimeSessionSecond;
    int TimeSessionThird;
    
    BOOL validateFaceDetectOK;

    BOOL isRequestWebService;

    BOOL isDoneProcess;
    
    BOOL isTakingPhoto;
    
    // sensors
    double pPitch;
    double pRoll;
    
    double pitchClose;
    double rollClose;
    
    double pitchAway;
    double rollAway;
    
    // Variables about popup reset
    PopUpValidationLiveness *popup;
    BOOL isPopUpShow;
    
    // Luminosity
    float luminosity;
    float luminosityAway;
    float luminosityClose;

    BOOL isStartLuminositySensor;
    
//    JGProgressHUD *HUD;

}

#pragma mark - Methods


- (void)popupHidden;


- (void)setIsDebug : (BOOL)debug;
- (void)successProcces : (NSString *)processId;

#pragma mark - Propertys

// * Configurable
@property (assign, nonatomic) BOOL debug;

// Class Swift to IA process
//@property (strong, nonatomic) FaceIA *faceIA;

@property (nonatomic) UIImageView *face;
@property (nonatomic) UIImageView *frame;

@property (strong, nonatomic) NSString *proccessId;

@property (strong, nonatomic) CameraBio *cam;

@property (strong, nonatomic) UILabel *lbIInstructions;

#pragma mark liveness

@property (strong, nonatomic) NSString *base64AwayWithoutSmilling;


@property (strong, nonatomic) NSString *base64Center;
@property (strong, nonatomic) NSString *base64Away;
@property (strong, nonatomic) NSString *base64Closer;



@property (strong, nonatomic) UIImage *imgCenter;
@property (strong, nonatomic) UIImage *imgAway;
@property (strong, nonatomic) UIImage *imgCloser;
@property (strong, nonatomic) UIImage *imgAwayWithoutSmile;


@property (assign, nonatomic) BOOL isFaceLiveness;

@property (assign, nonatomic) BOOL isLivenessSmilling;
@property (assign, nonatomic) BOOL isFinishiWithoutTheSmile;
@property (assign, nonatomic) BOOL isLivenessBlinking;

@property (strong, nonatomic) NSDictionary *dictUserLiveness;

@property (assign, nonatomic) BOOL isCommingFromResult;

#pragma mark sensors

@property (strong,nonatomic) CMMotionManager *motionManager;

@property (strong, nonatomic) NSString *URL;
@property (strong, nonatomic) NSString *APIKEY;
@property (strong, nonatomic) NSString *TOKEN;


@property (assign, nonatomic) BOOL isEnableAutoCapture;
@property (assign, nonatomic) BOOL isEnableSmartCapture;


@property (assign, nonatomic) BOOL isFacesCompareOneToOne;
@property (strong, nonatomic) NSString *cpfToFacesCompare;

@property(nonatomic, strong) AcessoBioManager *acessiBioManager;

@property (strong, nonatomic) UIColor *colorSilhoutteNeutral;
@property (strong, nonatomic) UIColor *colorSilhoutteSuccess;
@property (strong, nonatomic) UIColor *colorSilhoutteError;
@property (strong, nonatomic) UIColor *colorBackground;
@property (strong, nonatomic) UIColor *colorBackgroundBoxStatus;
@property (strong, nonatomic) UIColor *colorTextBoxStatus;

@end

NS_ASSUME_NONNULL_END
