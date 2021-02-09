//
//  LivenessXView.m
//  CaptureAcesso
//
//  Created by Matheus Domingos on 10/05/20.
//  Copyright © 2020 Matheus  domingos. All rights reserved.
//

#import "LivenessXView.h"

#import <sys/utsname.h> // import it in your header or implementation file.
#import "ValidateLiveness.h"


NSString *apiKeyDebug = @"";
NSString *urlDebug = @"";
NSString *userDebug = @"";
NSString *passwordDebug = @"";

BOOL isDebug = NO;

float topOffsetPercentLivenessX = 30.0f;
float sizeBetweenTopAndBottomPercentLivenessX = 50.0f;
float marginOfSidesLivenessX = 80.0f;

@interface LivenessXView ()

@end

@implementation LivenessXView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isSmillingUpponEnter = YES;
    
    arrLeftEyeOpenProbability = [NSMutableArray new];
    
    [self registerNotifications];
    
    countDown = 1;
    
    [self setOffsetTopPercent:30.0f];
    [self setSizePercentBetweenTopAndBottom:20.0f];
    
    isSelfie = YES;
    [self setupCamera:isSelfie];
    [self startCamera];
    
    [self.btTakePic setHidden:YES];
    [self setNewValuesToParamsLiveness];
    
    [self initVariables];
    
    [self initialActionOfChangeState:NO];
    [self addFullBrightnessToScreen];
    
    scaleMain = [UIScreen mainScreen].scale;
    
    [self gyroscope];
    
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"resultadoIAClose" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"resultadoIAAway" object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
}

#pragma mark - Close

- (void)addCloseButton {
    
    btClose = [[UIButton alloc]initWithFrame:CGRectMake(7, 20, 70, 70)];
    [btClose setImage:[UIImage imageNamed:@"ic_close"] forState:UIControlStateNormal];
    [btClose addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btClose];
    
}

- (void)close{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Init variables

-(void)initVariables {
    
    resultFaceDetectBehavior = 0; // 1 = Face Match / 2 = Both substandard / 3 = Not match
    resultFaceDetect = 0; // 1 = Face Match / 2 = Both substandard / 3 = Not match
    
    base64ToUsage = @"";
    
    facesNoMatchInFaceDetect = NO;
    
    SESSION = 0;
    
    TimeSessionFirst = 0;
    TimeSessionSecond = 0;
    TimeSessionThird = 0;
    
    isRequestWebService = NO;
    
    isDoneProcess = NO;
    
}


#pragma mark - Flash

- (void)fireFlash {
    
    if(vFlash == nil) {
        
        vFlash= [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [vFlash setBackgroundColor:[UIColor whiteColor]];
        [vFlash setAlpha:0.9];
        
        if(lStateType != LivenessStateCenterFace) {
            
            UIColor *colorBackground = [UIColor colorWithRed:57.0f/255.0f green:74.0f/255.0f blue:98.0f/255.0f  alpha:0.9f];
            
            if(self.colorBackground != nil) {
                colorBackground = self.colorBackground;
            }
            [vFlash setBackgroundColor:colorBackground];

            spinFlash = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            if (@available(iOS 13.0, *)) {
                [spinFlash setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleLarge];
            } else {
                // Fallback on earlier versions
                [spinFlash setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
            }
            
            UIColor *colorSpin  = [UIColor whiteColor];
            if(self.colorSilhoutteNeutral != nil) {
                colorSpin = self.colorSilhoutteNeutral;
            }
            [spinFlash setColor:colorSpin];
            spinFlash.center = self.view.center;
            [spinFlash startAnimating];
            [self.view addSubview:spinFlash];

        }
        
        [self.view addSubview:vFlash];
        
    }
    
}

- (void)removeFlash {
    
    [spinFlash stopAnimating];
    [spinFlash removeFromSuperview];
    [vFlash removeFromSuperview];
    vFlash = nil;
    spinFlash = nil;
    
}

#pragma mark - Adjust Brightness Of Screen

- (void)addFullBrightnessToScreen {
    [UIScreen mainScreen].brightness = 1.0;
}

- (void)setNewValuesToParamsLiveness {
    marginOfSidesLivenessX = 60.0f;
}


- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            /* start special animation */
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            /* start special animation */
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            /* start special animation */
            [self showRed];
            break;
            
        case UIDeviceOrientationLandscapeRight:
            [self showRed];
            break;
            
        default:
            break;
    };
}


- (void)registerNotifications {
    
    // Registrando alteracao de orientacao
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
}

#pragma mark - Resultado IA

- (void)getResultadoIACloseObjc:(NSDictionary *)dictIA {
    
    dictLivenessResultCenter = dictIA;
    [self readModelOBJC:self.imgAwayWithoutSmile isAway:YES];
    
}

- (void)getResultadoIAAwayObjc:(NSDictionary *)dictIA {
    
    dictLivenessResultAway = dictIA;
    [self validateLiveness];
    
}


#pragma mark - Read Model IA


- (void)readModelOBJC: (UIImage *) image isAway: (BOOL)isAway {
    
    if (@available(iOS 11.0, *)) {
        
        MLModel *model;
        VNCoreMLModel *m;
        VNCoreMLRequest *request;
        
        NSBundle *bundle = [NSBundle mainBundle];
        NSURL *centerModelURL = [bundle URLForResource: @"CenterModelCrop" withExtension: @"mlmodel"];
        NSURL *mobAwayModelURL = [bundle URLForResource: @"CenterModelCrop" withExtension: @"mlmodel"];
        
        NSError *err;
        if ([centerModelURL checkResourceIsReachableAndReturnError:&err] == NO)
            NSLog(@"%@", err);
        
        if ([mobAwayModelURL checkResourceIsReachableAndReturnError:&err] == NO)
            NSLog(@"%@", err);
        
        // Compile is Magic. This is trick to library.
        NSURL *urlCenterModel = [MLModel compileModelAtURL:centerModelURL error:&err];
        NSURL *urlAwayModel = [MLModel compileModelAtURL:mobAwayModelURL error:&err];
        
        if(isAway) {
            model = [[[CenterModelCrop alloc] initWithContentsOfURL:urlAwayModel error:&err] model];
        }else{
            model = [[[CenterModelCrop alloc] initWithContentsOfURL:urlCenterModel error:&err] model];
        }
        
        m = [VNCoreMLModel modelForMLModel: model error:nil];
        request = [[VNCoreMLRequest alloc] initWithModel: m completionHandler: (VNRequestCompletionHandler) ^(VNRequest *request, NSError *error){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSInteger numberOfResults = request.results.count;
                NSArray *results = [request.results copy];
                VNClassificationObservation *topResult = ((VNClassificationObservation *)(results[0]));
                NSString *messageLabel = [NSString stringWithFormat: @"%f: %@", topResult.confidence, topResult.identifier];
                
                int intIdentifier = 1;
                if([topResult.identifier isEqualToString:@"fotodefoto"]) {
                    intIdentifier = 0;
                }
                
                NSDictionary *resultDict = @{@"confidence" : [NSNumber numberWithFloat:topResult.confidence], @"fotoboa": [NSNumber numberWithInt:intIdentifier]};
                
                if(isAway) {
                    [self getResultadoIAAwayObjc:resultDict];
                }else{
                    [self getResultadoIACloseObjc:resultDict];
                }
                
            });
        }];
        
        request.imageCropAndScaleOption = VNImageCropAndScaleOptionCenterCrop;
        
        CIImage *coreGraphicsImage = [[CIImage alloc] initWithImage:image];
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
            VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCIImage:coreGraphicsImage  options:@{}];
            [handler performRequests:@[request] error:nil];
        });
        
    }
    
    
}

#pragma mark - Setup Hole Transparent

- (void)initHoleView {
    
    [self setParamsRectFaces];
    
    if(vHole != nil) {
        [vHole removeFromSuperview];
    }
    
    [self removeFlash];
    
    self->frameCurrent = frameFaceCenter;
    
    UIColor *colorBackground = [UIColor colorWithRed:57.0f/255.0f green:74.0f/255.0f blue:98.0f/255.0f  alpha:0.9f];
    
    if(self.colorBackground != nil) {
        colorBackground = self.colorBackground;
    }
    
    vHole = [[UIViewWithHole alloc] initWithFrame:self.view.frame backgroundColor:colorBackground andTransparentRect:frameFaceCenter cornerRadius:0];
    [self.view addSubview:vHole];
    [self addImageAcessoBio];
    
}

- (void)addVHole: (CGRect) rect  {
    
    [self->vHole removeFromSuperview];
    
    UIColor *colorBackground = [UIColor colorWithRed:57.0f/255.0f green:74.0f/255.0f blue:98.0f/255.0f  alpha:0.9f];
    
    if(self.colorBackground != nil) {
        colorBackground = self.colorBackground;
    }
    
    self->vHole = [[UIViewWithHole alloc] initWithFrame:self.view.frame backgroundColor:colorBackground andTransparentRect:rect cornerRadius:0];
    [self.view addSubview:self->vHole];
    
}

- (void)removeVHole {
    [self->vHole removeFromSuperview];
    [self->vAlert removeFromSuperview];
    [self.view bringSubviewToFront:self->btClose];
}

- (void)changeHoleView: (CGRect) newRect delayInSeconds: (double)delayInSeconds {
    
    if(!CGRectEqualToRect(newRect, CGRectZero)) {
        self->frameCurrent = newRect;
    }
    
    isSuccessAnimated = NO;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self addVHole:newRect];
            [self.view bringSubviewToFront:self->vAlert];
            [self.view bringSubviewToFront:self->btClose];
            [self.view bringSubviewToFront:self->ivAcessoBio];
            
            self->isProccessIA = NO;
            
        });
        
    });
    
}

- (void)setParamsRectFaces {
    
    float wCenter = 250.0f;
    float hCenter = 400.0f;
    
    float wAway = 180.0f;
    float hAway = 280.0f;

    frameFaceCenter = CGRectMake((SCREEN_WIDTH/2) - (wCenter / 2) ,(SCREEN_HEIGHT/2) - 180, wCenter, hCenter);
    
    if(scaleMain > 2) {
        wAway = 210.0f;
        hAway = 310.0f;
        frameFaceAway = CGRectMake((SCREEN_WIDTH/2) - (wAway / 2) ,(SCREEN_HEIGHT/2) - (hAway / 2), wAway, hAway);
    }else{
        frameFaceAway = CGRectMake((SCREEN_WIDTH/2) - (wAway / 2) ,(SCREEN_HEIGHT/2) - (hAway / 2), wAway, hAway);
    }
        
}

#pragma mark - Setup Camera

- (void) setupCamera:(BOOL) isSelfie {
    [super setupCamera:isSelfie];
    
    [self.view addSubview:self.btTakePic];
    
}

- (void) startCamera {
    [self.session startRunning];
}

- (void) stopCamera {
    [self.session stopRunning];
}

- (void)setIsDebug : (BOOL)debug {
    self.debug = debug;
    
    if(self.debug) {
        
        UIButton *btClear = [[UIButton alloc]initWithFrame:CGRectMake(20, SCREEN_HEIGHT - 100 , 80, 50)];
        [btClear setTitle:@"RESET" forState:UIControlStateNormal];
        [btClear.titleLabel setFont:[UIFont fontWithName:@"Avenir-Book" size:14.0]];
        [btClear setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btClear setBackgroundColor:[UIColor blackColor]];
        [btClear addTarget:self action:@selector(clearDots) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btClear];
        
        viewLog = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 160)];
        [viewLog setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:viewLog];
        
        lbLeftEye = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 150, 20)];
        [lbLeftEye setFont:[UIFont systemFontOfSize:10.0]];
        [lbLeftEye setTextColor: [UIColor blackColor]];
        [lbLeftEye setTag:-1];
        [viewLog addSubview:lbLeftEye];
        
        lbRightEye = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 150, 20)];
        [lbRightEye setFont:[UIFont systemFontOfSize:10.0]];
        [lbRightEye setTextColor: [UIColor blackColor]];
        [lbRightEye setTag:-1];
        [viewLog addSubview:lbRightEye];
        
        lbNosePosition = [[UILabel alloc]initWithFrame:CGRectMake(10, 60, 150, 20)];
        [lbNosePosition setFont:[UIFont systemFontOfSize:10.0]];
        [lbNosePosition setTextColor: [UIColor blackColor]];
        [lbNosePosition setTag:-1];
        [viewLog addSubview:lbNosePosition];
        
        lbLeftEar = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 150, 20)];
        [lbLeftEar setFont:[UIFont systemFontOfSize:10.0]];
        [lbLeftEar setTextColor: [UIColor blackColor]];
        [lbLeftEar setTag:-1];
        [viewLog addSubview:lbLeftEar];
        
        lbRightEar = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, 150, 20)];
        [lbRightEar setFont:[UIFont systemFontOfSize:10.0]];
        [lbRightEar setTextColor: [UIColor blackColor]];
        [lbRightEar setTag:-1];
        [viewLog addSubview:lbRightEar];
        
        lbEulerX = [[UILabel alloc]initWithFrame:CGRectMake(10, 120, 150, 20)];
        [lbEulerX setFont:[UIFont systemFontOfSize:10.0]];
        [lbEulerX setTextColor: [UIColor blackColor]];
        [lbEulerX setTag:-1];
        [viewLog addSubview:lbEulerX];
        
        lbSpaceEye = [[UILabel alloc]initWithFrame:CGRectMake(10, 140, 150, 20)];
        [lbSpaceEye setFont:[UIFont systemFontOfSize:10.0]];
        [lbSpaceEye setTextColor: [UIColor blackColor]];
        [lbEulerX setTag:-1];
        [viewLog addSubview:lbSpaceEye];
        
        UIView *v1 = [[UIView alloc]initWithFrame:CGRectMake(0, topOffsetPercentLivenessX, SCREEN_WIDTH, 2)];
        [v1 setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:v1];
        
        UIView *v2 = [[UIView alloc]initWithFrame:CGRectMake(0, sizeBetweenTopAndBottomPercentLivenessX, SCREEN_WIDTH, 2)];
        [v2 setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:v2];
        
        UIView *v3 = [[UIView alloc]initWithFrame:CGRectMake(marginOfSidesLivenessX, 0, 2, SCREEN_HEIGHT)];
        [v3 setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:v3];
        
        UIView *v4 = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - marginOfSidesLivenessX, 0, 2, SCREEN_HEIGHT)];
        [v4 setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:v4];
        
    }
    
}

- (void)setOffsetTopPercent : (float)percent {
    topOffsetPercentLivenessX = percent/100 *  SCREEN_HEIGHT;
}

- (void)setSizePercentBetweenTopAndBottom  : (float)percent {
    float pixels = percent/100 *  SCREEN_HEIGHT;
    sizeBetweenTopAndBottomPercentLivenessX = topOffsetPercentLivenessX + pixels;
}

- (void)setMarginOfSides: (float)margin {
    marginOfSidesLivenessX = margin;
}

- (void)clearDots {
    for (UIView *view in [self.view subviews]) {
        if(view.tag == - 1) {
            [view removeFromSuperview];
        }
    }
}

- (void)addCircleToPoint : (CGPoint) point color : (UIColor *)color{
    
    CGFloat widht = 10;
    
    CGFloat POINT_X = point.x;
    CGFloat POINT_Y = point.y;
    
    CGRect circleRect = CGRectMake(POINT_X - (widht / 2), POINT_Y - (widht / 2), widht, widht);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIView *circleView = [[UIView alloc] initWithFrame:circleRect];
        circleView.layer.cornerRadius = widht/2;
        circleView.alpha = 0.7;
        circleView.backgroundColor = color;
        circleView.tag = -1;
        [self.view addSubview:circleView];
        
    });
    
}

- (void)addLabelToLog : (CGPoint) point type : (NSString * )type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([type isEqualToString:@"left_eye"]) {
            [self->lbLeftEye setText:[NSString stringWithFormat:@"Leyft eye - X: %.0f Y: %.0f", point.x, point.y]];
        }else if([type isEqualToString:@"right_eye"]) {
            [self->lbRightEye setText:[NSString stringWithFormat:@"Right eye - X: %.0f Y: %.0f", point.x, point.y]];
        }if([type isEqualToString:@"left_ear"]) {
            [self->lbLeftEar setText:[NSString stringWithFormat:@"Leyft ear - X: %.0f Y: %.0f", point.x, point.y]];
        }else if([type isEqualToString:@"right_ear"]) {
            [self->lbRightEar setText:[NSString stringWithFormat:@"Right ear - X: %.0f Y: %.0f", point.x, point.y]];
        }else if([type isEqualToString:@"euler"]) {
            [self->lbEulerX setText:[NSString stringWithFormat:@"Euler X: %.0f Y: %.0f", point.x, point.y]];
        }else if([type isEqualToString:@"space-eye"]) {
            [self->lbSpaceEye setText:[NSString stringWithFormat:@"Space eye: %.0f", point.x]];
        }else{
            [self->lbNosePosition setText:[NSString stringWithFormat:@"Base nose - X: %.0f Y: %.0f", point.x, point.y]];
        }
        
    });
    
}

- (void) capture {
    
    if(!isDoneProcess) {
        
        if(!self->isProccessIA) {
            
            if(!isTakingPhoto) {
                isTakingPhoto = YES;
                
                
                if(self->isPhotoAwayToCapture) {
                    [self take];
                    
                }else{
                    
                    if(lStateType == LivenessStateCenterFace) {
                    }
                    
                    [self fireFlash];
                    
                    
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self take];
                    });
                    
                }
                
                
            }
            
        }
    }
    
}


- (void)take {
    
    AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef sampleBuffer, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            [self.renderLock lock];
            [self.renderLock unlock];
            
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
            UIImage *capturedImage = [[UIImage alloc] initWithData:imageData];
            
            if (self.defaultCamera == AVCaptureDevicePositionFront) {
                capturedImage = [UIImageUtils flipImage:[UIImageUtils imageRotatedByDegrees:capturedImage deg:-90]];
            } else {
                capturedImage = [UIImageUtils imageRotatedByDegrees:capturedImage deg:90];
            }
            
            // [self stopCamera];
            //[self generateHashFromImage:capturedImage];
            
            NSString* base64;
            base64 = [UIImageUtils getBase64Image: capturedImage]; // Utilizar esse base64 para a validação no WebService
            
            if(self->isPhotoAwayToCapture) {
                self->isPhotoAwayToCapture = NO;
                self->isTakingPhoto  = NO;
                self->_base64AwayWithoutSmilling = base64;
                self.imgAwayWithoutSmile = capturedImage;
            }else{
                //Como é assincrono, eu defino como processando a IA e disparo uma action dps de 3 segundos verificando se a thread UI foi liberada. Caso nao, eu libero.
                
                self->isTakingPhoto  = NO;
                self->isProccessIA = YES;
                [self performSelector:@selector(resetVariableProcessIA) withObject:nil afterDelay:3.0];;
                [self actionAfterTakePicture:base64 image:capturedImage];
            }
            
        }
    }];
    
}

#pragma mark - Processamento de imagem

- (void)changeState: (LivenessStateType )lType {
    
    isShowAlertToLiveness = NO;
    
    switch (lType) {
            
        case LivenessStateCenterFace:
            
            lStateType = LivenessStateAwayFace;
            timeToTakeCenterPhoto = durationProcess;
            [self changeHoleView:self->frameFaceAway delayInSeconds:0.7];
            
            break;
            
        case LivenessStateAwayFace:
            
            if(!isStartProcessIA) {
                
                isStartProcessIA = YES;
                lStateType = LivenessStateDone;
                // [self createCustomAlert:@"Validando" message:@""];
                
                [self readModelOBJC:self.imgCenter isAway:NO];
                
            }
            
            break;
            
        default:
            break;
    }
    
}

- (void)validateLiveness {
    
    //    if(isDarkImage([self croppIngimage:self.imgAway toRect:CGRectMake(0, 0, 720, 300)])) {
    //       // [self popupShow];
    //        return;
    //    }
    
    isValidating = YES;
    
    [self removeVHole];
    // [self validateBlinking];
    
    BOOL fotoboaCenter = [[dictLivenessResultCenter valueForKey:@"fotoboa"] boolValue];
    float confidenceCenter = [[dictLivenessResultCenter valueForKey:@"confidence"] floatValue];
    
    BOOL fotoboaAway = [[dictLivenessResultAway valueForKey:@"fotoboa"] boolValue];
    float confidenceAway = [[dictLivenessResultAway valueForKey:@"confidence"] floatValue];
    
    if(!fotoboaCenter) {
        if(confidenceCenter > 0.8) {
            confidenceCenter = 1 - confidenceCenter;
        }else{
            fotoboaCenter = YES;
        }
    }
    
    if(!fotoboaAway) {
        
        if(confidenceAway > 0.8) {
            confidenceAway = 1 - confidenceAway;
        }else{
            fotoboaAway = YES;
        }
        
    }
    
    int timeLastSession = 0;
    if(SESSION == 0) {
        timeLastSession = TimeSessionFirst;
    }else if(SESSION == 1) {
        timeLastSession = TimeSessionSecond;
    }else if(SESSION == 2) {
        timeLastSession = TimeSessionThird;
    }
    
    int sessionWhichEnded = 0;
    sessionWhichEnded = SESSION + 1;
    
    NSDictionary *dictValidate = @{
        @"photoCloseLive": [NSNumber numberWithBool:fotoboaCenter],
        @"photoCloseConfidence": [NSNumber numberWithFloat:confidenceCenter],
        @"photoAwayLive": [NSNumber numberWithBool:fotoboaAway],
        @"photoAwayConfidence" : [NSNumber numberWithFloat:confidenceAway],
        @"isSmilling" : [NSNumber numberWithBool:self.isLivenessSmilling],
        @"isBlinking" : [NSNumber numberWithBool:self.isLivenessBlinking],
        @"userBlinks" : [NSNumber numberWithInt:userBlinks],
        @"isFastProcess" : [NSNumber numberWithBool:isFastProcess],
        @"isFinishiWithoutTheSmile" : [NSNumber numberWithBool:self.isFinishiWithoutTheSmile],
        @"timeLastSession" : [NSNumber numberWithInt:timeLastSession],
        @"sessionWhichEnded" : [NSNumber numberWithInt:sessionWhichEnded],
        @"timeToSmilling" : [NSNumber numberWithInt:timeToSmiling],
        @"timeTotalProcess": [NSNumber numberWithInt:durationProcess]
    };
    
    
    NSDictionary *result = [ValidateLiveness validateLivenessV2:dictValidate];
    fTotal = [[result valueForKey:@"total"] floatValue];
    _isFaceLiveness = [[result valueForKey:@"isLive"] boolValue];
    
    
    if(_isFaceLiveness){
        
        [self fireFlash];
        [self stopCamera];
        
        [self performSelector:@selector(forceDoneProcess) withObject:nil afterDelay:20];;
        [self faceDetect];
        [self faceDetectBehavior];
        
    }else{
        
        if([self verifySession]) {
            
            isValidating = NO;
            
            isRequestWebService = NO;
            [self removeFlash];
            [self startCamera];
            isStartProcessIA = NO;
            self->isShowAlertLiveness = NO;
            [self resetSessionSpoofing];
            
        }else{
            
            [self performSelector:@selector(forceDoneProcess) withObject:nil afterDelay:20];;
            [self stopCamera];
            self.isFaceLiveness = NO;
            [self sendBillingV3];
            
        }
        
        [self.view bringSubviewToFront:btClose];
        
    }
    
    isDoneValidate = YES;
    
}

- (void)validatTimeToProcess {
    
    if(!isRequestWebService) {
        
        durationProcess ++ ;
        
        if(SESSION == 0) {
            TimeSessionFirst++;
        }else if(SESSION == 1) {
            TimeSessionSecond++;
        }else if(SESSION == 2){
            TimeSessionThird++;
        }
        
        if(durationProcess > 10) {
            isFastProcess = NO;
        }else{
            isFastProcess = YES;
        }
        
    }
    
}

- (void) addImageAcessoBio {
    if(IS_IPHONE_X || IS_IPHONE_6P){
        ivAcessoBio = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH/2) - 50, SCREEN_HEIGHT - 70, 100, 40)];
        
    }else{
        ivAcessoBio = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH/2) - 50, SCREEN_HEIGHT - 50, 100, 40)];
        
    }
    [ivAcessoBio setImage:[UIImage imageNamed:@"ic_bio"]];
    [ivAcessoBio setContentMode:UIViewContentModeScaleAspectFit];
    [ivAcessoBio setTag:-99];
    [self.view addSubview:ivAcessoBio];
}

// Method is deprecated in the without Firebase version
-(void)validateBlinking {
    
    NSArray *floatBlink = [arrLeftEyeOpenProbability copy];
    
    int blinks = 0;
    int blinkPosition = 0;
    for (int x = 0; x < ([arrLeftEyeOpenProbability count]-1); x++) {
        // verifico se há ao menos uma correspondência anterior.
        
        if(x > 1) {
            
            float sProbability =  [[floatBlink objectAtIndex:x] floatValue];
            
            if(sProbability < 0.8f){
                float sProbabilityBefore = [[floatBlink objectAtIndex:x-1] floatValue];
                if(sProbabilityBefore > 0.9f) {
                    blinkPosition = x;
                }
            }
            
            if(x == (blinkPosition + 1) || x == (blinkPosition + 2)) {
                if(sProbability > 0.9f) {
                    blinks++;
                }
            }
            
        }
        
    }
    
    if(blinks >  0) {
        userBlinks = blinks;
        self.isLivenessBlinking = YES;
        
    }else{
        self.isLivenessBlinking = NO;
    }
    
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    // if ([self.renderLock tryLock]) {
    
    if(!isDoneProcess) {
        
        CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
        UIImage* image = [self converCIImageToUIImage:ciImage];
        
        if (self->isPopUpShow) {
            return;
        }
        
        NSDictionary *options = @{
            CIDetectorSmile : [NSNumber numberWithBool:YES],
            CIDetectorEyeBlink: [NSNumber numberWithBool:YES],
            CIDetectorImageOrientation: [NSNumber numberWithInt:4]
        };
        
        CIImage *personciImage = [CIImage imageWithCGImage:image.CGImage];
        
        NSDictionary *accuracy = @{CIDetectorAccuracy: CIDetectorAccuracyHigh};
        CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:accuracy];
        NSArray *faceFeatures = [faceDetector featuresInImage:personciImage options:options];
        
        if([faceFeatures count] > 0) {
            
            if([faceFeatures count] == 1) {
                
                self->countNoFace = 0;
                
                CIFaceFeature *face = [faceFeatures firstObject];
                
                if(face.hasMouthPosition) {
                    
                    BOOL blinking = face.rightEyeClosed && face.leftEyeClosed;
                    
                    if(blinking) {
                        userBlinks++;
                        self.isLivenessBlinking = YES;
                    }
                    
                    switch (self->lStateType) {
                        case LivenessStateCenterFace:
                            if(self->isShowAlertLiveness) {
                                return;
                            }
                            [self verifyFaceCenter:face];
                            break;
                        case LivenessStateAwayFace:
                            if(self->isShowAlertLiveness) {
                                return;
                            }
                            if(!self->isShowAlertToLiveness){
                                self->isShowAlertToLiveness = YES;
                            }
                            [self verifyFaceAway:face];
                            break;
                            
                        default:
                            break;
                    }
                    
                    
                    
                }else {
                    [self showGray];
                }
                
            }
            
        }else{
            
            self->countNoFace++;
            if(self->countNoFace >= 20) {
                [self showGray];
            }
            
        }
        
    }
    
    //    [self.renderLock unlock];
    
    // }
    
}


- (void)verifyFaceCenter : (CIFaceFeature *)face{
    countNoNose = 0;
    
    float scale = 2;

    
    CGPoint leftEyePosition = face.leftEyePosition;
    
    CGPoint rightEyePosition = face.rightEyePosition;
    
    // Olhos
    CGFloat X_LEFT_EYE_POINT = [self normalizeXPoint:leftEyePosition.x faceWidth:face.bounds.size.width];
    CGFloat Y_LEFT_EYE_POINT = [self normalizeYPoint:leftEyePosition.y faceHeight:face.bounds.size.height];
    
    if(self.debug) {
        [self addCircleToPoint:CGPointMake(X_LEFT_EYE_POINT, SCREEN_HEIGHT - ((face.bounds.size.height/2) + (leftEyePosition.y/2))) color:[UIColor redColor]];
    }

    CGFloat X_RIGHT_EYE_POINT = [self normalizeXPoint:rightEyePosition.x faceWidth:face.bounds.size.width];
    CGFloat Y_RIGHT_EYE_POINT = [self normalizeYPoint:rightEyePosition.y faceHeight:face.bounds.size.height];
    
    if(self.debug) {
        [self addCircleToPoint:CGPointMake(X_RIGHT_EYE_POINT, Y_RIGHT_EYE_POINT) color:[UIColor greenColor]];
    }
    
    CGFloat X_LEFT_EAR_POINT = face.bounds.origin.x/scale;
    CGFloat X_RIGHT_EAR_POINT = (face.bounds.origin.x + face.bounds.size.width)/scale;
    

    // Face Angle
    CGFloat FACE_ANGLE = 180 - fabs(face.faceAngle);
    
    BOOL hasError = NO;
    NSMutableString *strError = [NSMutableString new];
    
    int leftMargin = frameFaceCenter.origin.x;
    int rightMargin = (frameFaceCenter.origin.x + frameFaceCenter.size.width);
    
    float minimumDistance = 150.0f;
    if(scaleMain > 2) {
        minimumDistance = 84.0f;
    }
    
    float distanceBeetwenEyes = ((fabs(X_RIGHT_EYE_POINT - X_LEFT_EYE_POINT)) * 2);
    
//    NSLog(@"MINIMUM >>>> %.2f | DISTANCE >>>> %.2f", minimumDistance, distanceBeetwenEyes);
    
    if((fabs(Y_LEFT_EYE_POINT) < frameFaceCenter.origin.y || fabs(Y_LEFT_EYE_POINT) > (frameFaceCenter.origin.y + frameFaceCenter.size.height)) || (fabs(Y_RIGHT_EYE_POINT) < frameFaceCenter.origin.y || fabs(Y_RIGHT_EYE_POINT) > (frameFaceCenter.origin.y + frameFaceCenter.size.height))) {
        countTimeAlert ++;
        if(hasError){
            [strError appendString:@" / Center face"];
        }else{
            [strError appendString:@"Center face"];
        }
        hasError = YES;
    }else if(X_RIGHT_EAR_POINT > rightMargin || X_LEFT_EAR_POINT < leftMargin) {
        countTimeAlert ++;
        if(hasError){
            [strError appendString:@" / Put your face away"];
        }else{
            [strError appendString:@"Put your face away"];
        }
        hasError = YES;
        
    }else if(distanceBeetwenEyes < minimumDistance) {
        countTimeAlert ++;
        if(hasError){
            [strError appendString:@" / Bring the face closer"];
        }else{
            [strError appendString:@"Bring the face closer"];
        }
        
        hasError = YES;
        
    }else if((fabs(Y_LEFT_EYE_POINT - Y_RIGHT_EYE_POINT) > 20) || (fabs(Y_RIGHT_EYE_POINT - Y_LEFT_EYE_POINT) > 20)){
        countTimeAlert ++;
        if(hasError){
            [strError appendString:@" / Inclined face"];
        }else{
            [strError appendString:@"Inclined face"];
        }
        hasError = YES;
        
    }
    
    if(FACE_ANGLE > 20 || FACE_ANGLE < -20) {
        countTimeAlert ++;
        if(hasError){
            if(FACE_ANGLE > 20) {
                [strError appendString:@" / Turn slightly left"];
            }else if(FACE_ANGLE < -20){
                [strError appendString:@" / Turn slightly right"];
            }
        }else{
            if(FACE_ANGLE > 20) {
                [strError appendString:@"Turn slightly left"];
            }else if(FACE_ANGLE < -20){
                [strError appendString:@"Turn slightly right"];
            }
        }
        hasError = YES;
        
    }
    
    if(hasError) {
        [self faceIsNotOK:strError];
        hasError = NO;
    }else{
        [self faceIsOK];
    }
    
}

- (void)verifyFaceAway: (CIFaceFeature *)face{
    
    countNoNose = 0;
    
    //float scale = [UIScreen mainScreen].scale;
    float scale = 2;

    CGPoint leftEyePosition = face.leftEyePosition;
    
    CGPoint rightEyePosition = face.rightEyePosition;
    
    // Olhos
    CGFloat X_LEFT_EYE_POINT = [self normalizeXPoint:leftEyePosition.x faceWidth:face.bounds.size.width];
    CGFloat Y_LEFT_EYE_POINT = [self normalizeYPoint:leftEyePosition.y faceHeight:face.bounds.size.height];
    
    CGFloat X_RIGHT_EYE_POINT = [self normalizeXPoint:rightEyePosition.x faceWidth:face.bounds.size.width];
    CGFloat Y_RIGHT_EYE_POINT = [self normalizeYPoint:rightEyePosition.y faceHeight:face.bounds.size.height];
    
    CGFloat X_LEFT_EAR_POINT = face.bounds.origin.x/scale;
    CGFloat X_RIGHT_EAR_POINT = (face.bounds.origin.x + face.bounds.size.width)/scale;
    
    // Face Angle
    CGFloat FACE_ANGLE = 180 - fabs(face.faceAngle);
    
    BOOL hasError = NO;
    NSMutableString *strError = [NSMutableString new];
    
    int compensation = 12;
    int leftMargin = frameFaceAway.origin.x - compensation;
    int rightMargin = (frameFaceAway.origin.x + frameFaceAway.size.width) + compensation;
    
    float minimumDistance = 150.0f;
    if(scaleMain > 2) {
        minimumDistance = 84.0f;
    }
    
    float distanceBeetwenEyes = ((fabs(X_RIGHT_EYE_POINT - X_LEFT_EYE_POINT)) * 2);
        
    if((fabs(Y_LEFT_EYE_POINT) < frameFaceCenter.origin.y || fabs(Y_LEFT_EYE_POINT) > (frameFaceCenter.origin.y + frameFaceCenter.size.height)) || (fabs(Y_RIGHT_EYE_POINT) < frameFaceCenter.origin.y || fabs(Y_RIGHT_EYE_POINT) > (frameFaceCenter.origin.y + frameFaceCenter.size.height))) {
        countTimeAlert ++;
        if(hasError){
            [strError appendString:@" / Center face"];
        }else{
            [strError appendString:@"Center face"];
        }
        hasError = YES;
    }else if(X_RIGHT_EAR_POINT > rightMargin || X_LEFT_EAR_POINT < leftMargin) {
        countTimeAlert ++;
        if(hasError){
            [strError appendString:@" / Put your face away"];
        }else{
            [strError appendString:@"Put your face away"];
        }
        hasError = YES;
        
    }else if(distanceBeetwenEyes < minimumDistance) {
        countTimeAlert ++;
        if(hasError){
            [strError appendString:@" / Bring the face closer"];
        }else{
            [strError appendString:@"Bring the face closer"];
        }
        
        hasError = YES;
        
    }else if((fabs(Y_LEFT_EYE_POINT - Y_RIGHT_EYE_POINT) > 20) || (fabs(Y_RIGHT_EYE_POINT - Y_LEFT_EYE_POINT) > 20)){
        countTimeAlert ++;
        if(hasError){
            [strError appendString:@" / Inclined face"];
        }else{
            [strError appendString:@"Inclined face"];
        }
        hasError = YES;
        
    }
    
    if(FACE_ANGLE > 20 || FACE_ANGLE < -20) {
        countTimeAlert ++;
        if(hasError){
            if(FACE_ANGLE > 20) {
                [strError appendString:@" / Turn slightly left"];
            }else if(FACE_ANGLE < -20){
                [strError appendString:@" / Turn slightly right"];
            }
        }else{
            if(FACE_ANGLE > 20) {
                [strError appendString:@"Turn slightly left"];
            }else if(FACE_ANGLE < -20){
                [strError appendString:@"Turn slightly right"];
            }
        }
        hasError = YES;
        
    }
    
    delayToVerifySmilling ++;
    
    int timeToWaiting = 30;
    if(IS_IPHONE_6) {
        timeToWaiting = 13;
    }
    
    if(delayToVerifySmilling == (timeToWaiting - 10)) {
        if(self.base64AwayWithoutSmilling.length == 0) {
            isPhotoAwayToCapture = YES;
            [self capture];
        }
    }
    
    if(delayToVerifySmilling > timeToWaiting) {
        
        if(!isVerifiedSmillingUpponEnter) {
            if(!face.hasSmile) {
                isSmillingUpponEnter = NO;
            }
            
            isVerifiedSmillingUpponEnter = YES;
        }
        
        if(isSmillingUpponEnter) {
            
            if(face.hasSmile) {
                
                if(!hasError){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if(self->timerToSmiling == nil) {
                            self->timerToSmiling = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(incrementTimeToSmiling) userInfo:nil repeats:YES];
                        }
                        [self setMessageStatus:@"Dê um sorriso  \U0001F604"];
                        
                    });
                }
                
            }else{
                self.isLivenessSmilling = YES;
            }
            
        }else{
            
            if(!face.hasSmile) {
                //hasError = YES;
                
                if(!hasError){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if(self->timerToSmiling == nil) {
                            self->timerToSmiling = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(incrementTimeToSmiling) userInfo:nil repeats:YES];
                        }
                        [self setMessageStatus:@"Dê um sorriso  \U0001F604"];
                        
                    });
                }
                
                
            }else{
                self.isLivenessSmilling = YES;
            }
            
        }
        
    }
    
    if(hasError) {
        [self faceIsNotOK:strError];
        hasError = NO;
    }else{
        [self faceIsOK];
    }
    
}

- (void)showAlert : (NSString *)alert {
    
    if(countTimeAlert >= 10) {
        
        countTimeAlert = 0;
        isShowAlert = NO;
        
        [self showRed];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CATransition *animation = [CATransition animation];
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.type = kCATransitionFade;
            animation.duration = 0.75;
            [self->lbMessage.layer addAnimation:animation forKey:@"kCATransitionFade"];
            
            UIColor *colorLbMessage = [UIColor whiteColor];
            
            if(self.colorTextBoxStatus != nil) {
                colorLbMessage = self.colorTextBoxStatus;
            }
            [self->lbMessage setTextColor:colorLbMessage];
            
            if(self->lStateType == LivenessStateCenterFace){
                
                if([alert containsString:@"Bring the face closer"]) {
                    [self setMessageStatus:@"Aproxime o rosto"];
                }else if ([alert containsString:@"Put your face away"]){
                    [self setMessageStatus:@"Afaste o rosto"];
                }else{
                    [self setMessageStatus:@"Enquadre o seu rosto"];
                }
                
            }else if(self->lStateType == LivenessStateAwayFace){
                
                if([alert containsString:@"Center face"]){
                    [self setMessageStatus:@"Enquadre o seu rosto"];
                    [self->lbMessage setTextColor:colorLbMessage];
                }else if([alert containsString:@"Put your face away"]){
                    [self setMessageStatus:@"Afaste o rosto"];
                    [self->lbMessage setTextColor:colorLbMessage];
                }else if ([alert containsString:@"Bring the face closer"]){
                    [self setMessageStatus:@"Aproxime o rosto"];
                    [self->lbMessage setTextColor:colorLbMessage];
                }else{
                    [self setMessageStatus:@"Dê um sorriso  \U0001F604"];
                }
                
            }else{
                
                if([alert containsString:@"Bring the face closer"]){
                    [self setMessageStatus:@"Aproxime o rosto"];
                }else{
                    [self setMessageStatus:@"Dê um sorriso  \U0001F604"];
                }
            }
            
        });
        
    }
    
}

- (void)showRed{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self->timerCountDown != nil) {
            [self resetTimer];
        }
        
        [self resetSmilling];
        
        
        [self.btTakePic setAlpha:0.5];
        [self.btTakePic setEnabled:NO];
        
        UIColor *colorBorder  = [UIColor whiteColor];
        if(self.colorSilhoutteError != nil) {
            colorBorder = self.colorSilhoutteError;
        }
        
        self->vHole.shapeLayer.strokeColor = [colorBorder CGColor];
        
    });
    
}

- (void)showGray{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self->timerCountDown != nil) {
            [self resetTimer];
        }
        
        [self resetSmilling];
        [self setMessageStatus:@"Enquadre seu rosto"];
        
        UIColor *colorTextMessage  = [UIColor whiteColor];
        if(self.colorTextBoxStatus != nil) {
            colorTextMessage = self.colorTextBoxStatus;
        }
        
        [self->lbMessage setTextColor:colorTextMessage];
        
        
        UIColor *colorBorder  = [UIColor whiteColor];
        if(self.colorSilhoutteNeutral != nil) {
            colorBorder = self.colorSilhoutteNeutral;
        }
        
        self->vHole.shapeLayer.strokeColor = [colorBorder CGColor];
        
        [self.btTakePic setAlpha:0.5];
        [self.btTakePic setEnabled:NO];

    });
    
}

- (void)faceIsNotOK: (NSString *)error {
    [self showAlert:error];
}

- (void)faceIsOK{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        if(self->lStateType == LivenessStateAwayFace) {
            
            if(self.isLivenessSmilling || self.isFinishiWithoutTheSmile) {
                [self capture];
            }else{
                if(!self->isResetRunning) {
                    self->isResetRunning = YES;
                    
                    self->timerToTakeCenterPhoto = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(incrementTimeToTakeCenterPhoto) userInfo:nil repeats:YES];
                    
                    [self performSelector:@selector(resetSession) withObject:nil afterDelay:10];;
                }
            }
            
        }else{
            
            if(!self->isCountDown) {
                [self createTimer];
                // [self performSelector:@selector(createTimer) withObject:nil afterDelay:0.5];;
                self->isCountDown = YES;
            }
            
            
        }
        
        
        if(!self->isProccessIA) {
            
            if(self->lStateType != LivenessStateAwayFace) {
                [self->vAlert setHidden:YES];
                [self setMessageStatus:@"Não se mexa..."];
            }
            
        }
        
        [self.btTakePic setAlpha:1];
        [self.btTakePic setEnabled:YES];
        
        UIColor *colorSuccess = [self getColorGreen];
        
        if(self.colorSilhoutteSuccess != nil) {
            colorSuccess = self.colorSilhoutteSuccess;
        }
        
        self->vHole.shapeLayer.strokeColor = [colorSuccess CGColor];
        
    });
    
}

#pragma mark - liveness_Session

// Initialize or restart params and variables to the session.
- (void)initSession {
    
    lbMessage.text = @"";
    isResetRunning = NO;
    
    self.base64Closer = @"";
    self.base64Center = @"";
    self.base64Away = @"";
    self.base64AwayWithoutSmilling = @"";
    
    [self resetSmilling];
    [self resetBlinking];
    
    if(timerToTakeCenterPhoto) {
        [timerToTakeCenterPhoto invalidate];
        timerToTakeCenterPhoto = nil;
    }
    
    if(timerToTakeAwayPhoto) {
        [timerToTakeAwayPhoto invalidate];
        timerToTakeAwayPhoto = nil;
    }
    
    resultFaceDetect = 0;
    resultFaceDetectBehavior = 0;
    
    lStateType = LivenessStateCenterFace;
    
}

- (void)resetBlinking {
    arrLeftEyeOpenProbability = [NSMutableArray new];
}

- (void)resetSession {
    
    if(!isValidating) {
        if(!isDoneValidate) {
            
            if(!self.isLivenessBlinking) {
                
                if([self verifySession]){
                    
                    [self initSession];
                    
                    SESSION++;
                    attemptsValidate ++;
                    isResetSessionValidate = YES;
                    
                    [self initialActionOfChangeState:YES];
                    
                }else{
                    
                    self.isFinishiWithoutTheSmile = YES;
                    
                }
            }
            
        }
    }
    
}

- (void)resetSessionSpoofing {
    
    if([self verifySession]){
        
        [self initSession];
        
        if(isResetSessionNoComputated) {
            isResetSessionNoComputated = NO;
        }else{
            isResetSessionSpoofing = YES;
            SESSION++;
            attemptsSpoofing ++;
        }
        
        [self initialActionOfChangeState:YES];
        
    }
    
}

- (bool)verifySession {
    
    if(SESSION < 3) {
        return YES;
    }else{
        return NO;
    }
    
}

- (void)resetSmilling{
    
    timeToSmiling = 0;
    delayToVerifySmilling = 0;
    isVerifiedSmillingUpponEnter = NO;
    isSmillingUpponEnter = YES;
    self.isLivenessSmilling = NO;
    [self invalidateTimerToSmiling];
    
}

- (void)resetTimer {
    [self->timerCountDown invalidate];
    self->countDown = 1.3;
    self->isCountDown = NO;
    self->timerCountDown = nil;
}

- (void)createTimer {
    
    if(lStateType != LivenessStateCenterFace) {
        countDown = 0;
    }
    
    self->timerCountDown = [NSTimer scheduledTimerWithTimeInterval:0.8
                                                            target:self
                                                          selector:@selector(countDown)
                                                          userInfo:nil
                                                           repeats:YES];
    
}

- (void)countDown {
    
    if(!isShowAlertLiveness) {
        if(countDown == 0) {
            if(!self->isSuccessAnimated) {
                self->isSuccessAnimated = YES;
                // [self->vHole startAnimationSuccess];
            }
            [self resetTimer];
            [self capture];
        }
        countDown --;
    }
    
}

- (void)switchCam {
    
    
    if(self.session)
    {
        //Indicate that some changes will be made to the session
        [self.session beginConfiguration];
        
        //Remove existing input
        AVCaptureInput* currentCameraInput = [self.session.inputs objectAtIndex:0];
        [self.session removeInput:currentCameraInput];
        
        //Get new input
        AVCaptureDevice *newCamera = nil;
        if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack)
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        else
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
        
        
        
        //Add input to session
        NSError *err = nil;
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
        if(!newVideoInput || err)
        {
            NSLog(@"Error creating capture device input: %@", err.localizedDescription);
        }
        else
        {
            [self.session addInput:newVideoInput];
        }
        
        //Commit all the configuration changes at once
        [self.session commitConfiguration];
    }
    
    
}

- (void)actionAfterTakePicture : (NSString *)base64 image:(UIImage *)image {
    
    isTakingPhoto = NO;
    
    switch (lStateType) {
        case LivenessStateCenterFace:
            
            [self removeFlash];
            _base64Center = base64;
            _imgCenter = image;
            pitchClose = pPitch;
            rollClose = pRoll;
            yawClose = pYaw;
            luminosityClose = luminosity;
            
            break;
        case LivenessStateAwayFace:
            
            _base64Away = base64;
            _imgAway = image;
            pitchAway = pPitch;
            rollAway = pRoll;
            yawAway = pYaw;
            luminosityAway = luminosity;
            
            break;
            
        default:
            break;
    }
    
    [self changeState:lStateType];
    
}

- (void)doneFaceInsert {
    
    //    if(self.cam != nil){
    //        [self.cam onSuccesCapture:self.base64Center];
    //    }
    
}


- (void)showAlertLivenessStep: (NSString *)message {
    
    isShowAlertLiveness = YES;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            //We add buttons to the alert controller by creating UIAlertActions:
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Entendi"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action){
                self->isShowAlertLiveness = NO;
                
            }];
            [alertController addAction:actionOk];
            [self presentViewController:alertController animated:YES completion:nil];
            
            
        });
        
    });
    
}


- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero completionHandler:nil];
}

- (void)report {
    
}

- (void)invalidateAllTimers {
    
    if(timerProcesss != nil) {
        [timerProcesss invalidate];
        timerProcesss = nil;
    }
    
    if(timerToTakeCenterPhoto != nil) {
        [timerToTakeCenterPhoto invalidate];
        timerToTakeCenterPhoto = nil;
    }
    
    if(timerToTakeAwayPhoto != nil) {
        [timerToTakeAwayPhoto invalidate];
        timerToTakeAwayPhoto = nil;
    }
    
    [self invalidateTimerToSmiling];
    
}

- (void)invalidateTimerToSmiling {
    if(timerToSmiling != nil) {
        [timerToSmiling invalidate];
        timerToSmiling = nil;
    }
}


- (void)initialActionOfChangeState : (BOOL)fromReset {
    
    if(!isDoneProcess) {
        
        if(self->lStateType == LivenessStateDone){
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            
            if(self->lStateType == LivenessStateCenterFace) {
                
                if(timerProcesss == nil) {
                    timerProcesss = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(validatTimeToProcess) userInfo:nil repeats:YES];
                }
                
                
                timerToTakeCenterPhoto = nil;
                timerToTakeAwayPhoto = nil;
                
                timerToTakeCenterPhoto = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(incrementTimeToTakeCenterPhoto) userInfo:nil repeats:YES];
                
                [self initHoleView];
                [self createViewAlert];
                [self addCloseButton];
                
                if(fromReset) {
                    [self popupShow];
                }
                
            }else if(self->lStateType == LivenessStateAwayFace){
                
                timerToTakeCenterPhoto = nil;
                timerToTakeAwayPhoto = nil;
                
                timerToTakeAwayPhoto = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(incrementTimeToTakeAwayPhoto) userInfo:nil repeats:YES];
                
            }
            
        }
        
    }
    
}

- (void)resetVariableProcessIA {
    if(isProccessIA){
        isProccessIA = NO;
    }
}

- (void)incrementTimeToTakeCenterPhoto {
    if(!isRequestWebService)
        timeToTakeCenterPhoto ++;
}

- (void)incrementTimeToTakeAwayPhoto {
    if(!isRequestWebService)
        timeToTakeAwayPhoto ++;
}

- (void)incrementTimeToSmiling {
    if(!isRequestWebService)
        timeToSmiling ++;
}

- (void)createViewAlert {
    
    
    if(popup == nil) {
        
        vAlert = [[UIView alloc]initWithFrame:CGRectMake(50, (frameFaceCenter.origin.y - 25) , SCREEN_WIDTH - 100, 50)];
        
        UIColor *colorBackgroundBox = [UIColor colorWithRed:24.0f/255.0f green:30.0f/255.0f blue:45.0f/255.0f alpha:1.0];
        if(self.colorBackgroundBoxStatus != nil) {
            colorBackgroundBox = self.colorBackgroundBoxStatus;
        }
        [vAlert setBackgroundColor:colorBackgroundBox];
        [vAlert setAlpha:1.0f];
        [vAlert.layer setMasksToBounds:YES];
        [vAlert.layer setCornerRadius:10.0];
        [self.view addSubview:vAlert];
        
        //    vAlert.layer.shadowRadius  = 1.5f;
        //    vAlert.layer.shadowColor   = [UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:0.f/255.f alpha:1.f].CGColor;
        //    vAlert.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
        //    vAlert.layer.shadowOpacity = 0.5f;
        //    vAlert.layer.masksToBounds = NO;
        //
        //    UIEdgeInsets shadowInsets     = UIEdgeInsetsMake(0, 0, -1.5f, 0);
        //    UIBezierPath *shadowPath      = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(vAlert.bounds, shadowInsets)];
        //    vAlert.layer.shadowPath    = shadowPath.CGPath;
        
        lbMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, vAlert.frame.size.width, 50)];
        [lbMessage setText:@"Enquadre seu rosto"];
        [lbMessage setMinimumScaleFactor:0.5];
        
        
        UIColor *colorLbMessage = [UIColor whiteColor];
        
        if(self.colorTextBoxStatus != nil) {
            colorLbMessage = self.colorTextBoxStatus;
        }
        [lbMessage setTextColor:colorLbMessage];
        
        [lbMessage setBackgroundColor:colorBackgroundBox];
        
        [lbMessage setTextAlignment:NSTextAlignmentCenter];
        [lbMessage setFont:[UIFont boldSystemFontOfSize:17.5]];
        [vAlert addSubview:lbMessage];
        
        //   [self startBlinkingLabel:lbMessage];
    }
    
}

- (void)fireAlert : (NSString *)message {
    
    
}

- (void)setMessageStatus: (NSString *)str {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self->popup == nil) {
            [self->vAlert setHidden:NO];
            [self->lbMessage setText:str];
        }else{
            [self->vAlert setHidden:YES];
            [self->lbMessage setText:@""];
        }
    });
    
}

-(void) startBlinkingLabel:(UILabel *)label
{
    label.alpha =1.0f;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionAutoreverse |UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        label.alpha = 0.0f;
    }
                     completion:^(BOOL finished){
        if (finished) {
            
        }
    }];
}

-(void) stopBlinkingLabel:(UILabel *)label
{
    // REMOVE ANIMATION
    [label.layer removeAnimationForKey:@"opacity"];
    label.alpha = 1.0f;
}


- (void)forceDoneProcess {
    
    if(!validateFaceDetectOK) {
        [self doneProcess];
    }
    
}

- (void)doneProcess {
    
    //    if(HUD != nil) {
    //        HUD.progress = 1.0f;
    //    }
    
    if(!isDoneProcess){
        [self invalidateAllTimers];
        
        isDoneProcess = YES;
        [self stopCamera];
        
        if(livenessXResult != nil) {
            
            [self dismissViewControllerAnimated:YES completion:^{
                [self.acessiBioManager onSuccesLivenessX:self->livenessXResult];
            }];
            
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
        
    }
    
}

- (void)exitError {
    [self invalidateAllTimers];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Face Detect
- (void)faceDetect {

    validateFaceDetectOK = NO;
    isRequestWebService = YES;
    
    
    if(self.base64AwayWithoutSmilling.length == 0) {
        self.base64AwayWithoutSmilling = self.base64Away;
    }
    
    NSDictionary *dict = @{
        @"imageBase641" : _base64Center,
        @"imageBase642" : _base64AwayWithoutSmilling
    };
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/services/v3/AcessoService.svc/faces/detect", self.URL]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestMain:url params:dict] completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
      
        if (data.length > 0 && error == nil)
        {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:NULL];
            //NSString * string = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
            
            int FaceResult = [[response valueForKey:@"FaceResult"] intValue];
            BOOL Similars = [[response valueForKey:@"Similars"] boolValue];
            double SimilarScore = [[response valueForKey:@"SimilarScore"] doubleValue];
            
            if(FaceResult == 0){
                self->resultFaceDetect = 2;
            }else if (!Similars) {
                self->resultFaceDetect = 3;
            }else{
                self->scoreFacedetect = SimilarScore;
                self->resultFaceDetect = 1;
            }
            
            if(FaceResult != 0) {
                if(FaceResult == 1){
                    self->base64ToUsage = self->_base64Center;
                }else if(FaceResult == 2){
                    self->base64ToUsage = self->_base64AwayWithoutSmilling;
                }
            }
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self validateFaceDetect];
                });
            });
            
        }else {
            
            self->isRequestWebService = NO;
            
            if(self.debug) {
                NSLog(@"Error: %@", error);
            }
            
            NSData *data = [error.description dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if([json isKindOfClass:[NSDictionary class]]) {
                NSDictionary *error = [json valueForKey:@"Error"];
                NSString *description = [error valueForKey:@"Description"];
                [self.acessiBioManager onErrorLivenessX:[self strErrorFormatted:@"faceDetect" description:description]];
            }else{
                [self.acessiBioManager onErrorLivenessX:[self strErrorFormatted:@"faceDetect" description:@"Verifique sua url de conexão, apikey e token. Se persistir, entre em contato com a equipe da Acesso."]];
            }
            
            [self exitError];
        }
        
    }] resume];
    
}

- (void)faceDetectBehavior {

    isRequestWebService = YES;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/services/v3/AcessoService.svc/faces/detect", self.URL]];
    
    NSDictionary *dict = @{
        @"imageBase641" : self.base64AwayWithoutSmilling,
        @"imageBase642" : self.base64Away
    };

    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestMain:url params:dict] completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
      
        if (data.length > 0 && error == nil)
        {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:NULL];
            //NSString * string = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
                        
            int FaceResult = [[response valueForKey:@"FaceResult"] intValue];
            BOOL Similars = [[response valueForKey:@"Similars"] boolValue];
            
            if(FaceResult == 0){
                self->resultFaceDetectBehavior = 2;
            }else if (!Similars) {
                self->resultFaceDetectBehavior = 3;
            }else{
                self->resultFaceDetectBehavior = 1;
            }
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self validateFaceDetect];
                });
            });
            
        }else {
        
            self->isRequestWebService = NO;
                    
            if(self.debug) {
                NSLog(@"Error: %@", error);
            }
            
            NSData *data = [error.description dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if([json isKindOfClass:[NSDictionary class]]) {
                NSDictionary *error = [json valueForKey:@"Error"];
                NSString *description = [error valueForKey:@"Description"];
                [self.acessiBioManager onErrorLivenessX:[self strErrorFormatted:@"faceDetectBehavior" description:description]];
            }else{
                [self.acessiBioManager onErrorLivenessX:[self strErrorFormatted:@"faceDetectBehavior" description:@"Verifique sua url de conexão, apikey e token. Se persistir, entre em contato com a equipe da Acesso."]];
            }
            
            [self exitError];
        }
        
    }] resume];
    
}

-(void) validateFaceDetect{
    
    // Verify if both request have a return response
    if(resultFaceDetectBehavior == 0 || resultFaceDetect == 0) {
        
        //        if(HUD != nil) {
        //            HUD.progress = 0.6f;
        //        }
        
        return;
    }else{
        validateFaceDetectOK = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self]; // Cancel perform selectors with the target like a self
    }
    
    // Both substandard
    if(resultFaceDetect == 2){
        
        [self removeFlash];
        [self startCamera];
        
        isRequestWebService = NO;
        isValidating = NO;
        
        isResetSessionNoComputated = YES;  // para resetar sem contar como uma sessão a mais.
        [self resetSessionSpoofing];
        
    }else if(resultFaceDetect == 3 || resultFaceDetectBehavior == 3) { // Not match
        
        if([self verifySession]) {
            
            isRequestWebService = NO;
            isValidating = NO;
            
            [self removeFlash];
            [self startCamera];
            isStartProcessIA = NO;
            self->isShowAlertLiveness = NO;
            [self resetSessionSpoofing];
            
        }else{
            
            self.isFaceLiveness = NO;
            [self sendBillingV3];
            
        }
        
    }else if(resultFaceDetectBehavior == 1 && resultFaceDetect == 1) { // Match faces
        
        //        if(HUD != nil) {
        //            HUD.progress = 0.8f;
        //        }
        
        [self sendBillingV3];
        
    }
    
}

#pragma mark - Send Billing v3

- (void)sendBillingV3 {
    
    isRequestWebService = YES;
    
        

    NSUUID *uuid = [NSUUID UUID];
    NSString *strUuid = [uuid UUIDString];
    NSString *status = [NSString stringWithFormat:@"%@", [NSNumber numberWithBool:self.isFaceLiveness]];
    
    if([status isEqualToString:@"0"]){
        status = @"2";
    }

    BOOL fotoboaCenter = [[dictLivenessResultCenter valueForKey:@"fotoboa"] boolValue];
    double confidenceCenter = [[dictLivenessResultCenter valueForKey:@"confidence"] doubleValue];
    
    BOOL fotoboaAway = [[dictLivenessResultAway valueForKey:@"fotoboa"] boolValue];
    double confidenceAway = [[dictLivenessResultAway valueForKey:@"confidence"] doubleValue];
    
    if(!fotoboaCenter) {
        if(confidenceCenter > 0.8) {
            confidenceCenter = 1 - confidenceCenter;
        }else{
            fotoboaCenter = YES;
        }
    }
    
    if(!fotoboaAway) {
        
        if(confidenceAway > 0.8) {
            confidenceAway = 1 - confidenceAway;
        }else{
            fotoboaAway = YES;
        }
        
    }
    
    if(self.base64AwayWithoutSmilling.length == 0) {
        self.base64AwayWithoutSmilling = self.base64Away;
    }
    
    NSMutableArray *fields = [NSMutableArray new];
    [fields addObject:[self getDictField:@"isLive" value:[NSString stringWithFormat:@"%@", [NSNumber numberWithBool:self.isFaceLiveness]]]];
    [fields addObject:[self getDictField:@"Score" value:[NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:fTotal]]]];
    [fields addObject:[self getDictField:@"isLiveClose" value:[NSString stringWithFormat:@"%@", [NSNumber numberWithBool:fotoboaCenter]]]];
    [fields addObject:[self getDictField:@"ScoreClose" value:[NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:confidenceCenter]]]];
    [fields addObject:[self getDictField:@"isLiveAway" value:[NSString stringWithFormat:@"%@", [NSNumber numberWithBool:fotoboaAway]]]];
    [fields addObject:[self getDictField:@"ScoreAway" value:[NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:confidenceAway]]]];
    [fields addObject:[self getDictField:@"IsBlinking" value:[NSString stringWithFormat:@"%@", [NSNumber numberWithBool:self.isLivenessBlinking]]]];
    [fields addObject:[self getDictField:@"IsSmilling" value:[NSString stringWithFormat:@"%@", [NSNumber numberWithBool:self.isLivenessSmilling]]]];
    [fields addObject:[self getDictField:@"DeviceModel" value:[self deviceName]]];
    //    [fields addObject:[self getDictField:@"Base64Center" value: self.base64Center]];
    //    [fields addObject:[self getDictField:@"Base64Away" value: self.base64AwayWithoutSmilling]];
    [fields addObject:[self getDictField:@"IsResetSession" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithBool:isResetSessionValidate]]]];
    [fields addObject:[self getDictField:@"AttemptsValidate" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithInt:attemptsValidate]]]];
    [fields addObject:[self getDictField:@"IsResetSessionSpoofing" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithBool:isResetSessionSpoofing]]]];
    [fields addObject:[self getDictField:@"AttemptsSpoofing" value:  [NSString stringWithFormat:@"%@", [NSNumber numberWithInt:attemptsSpoofing]]]];
    [fields addObject:[self getDictField:@"TimeTotal" value:  [NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:durationProcess]]]];
    [fields addObject:[self getDictField:@"Blinks" value:  [NSString stringWithFormat:@"%@", [NSNumber numberWithInt:userBlinks]]]];
    [fields addObject:[self getDictField:@"TimeSmilling" value: [NSString stringWithFormat:@"%@",  [NSNumber numberWithInt:timeToSmiling]]]];
    [fields addObject:[self getDictField:@"TimeSessionFirst" value:  [NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:TimeSessionFirst]]]];
    [fields addObject:[self getDictField:@"TimeSessionSecond" value:  [NSString stringWithFormat:@"%@", [NSNumber numberWithInt:TimeSessionSecond]]]];
    [fields addObject:[self getDictField:@"TimeSessionThird" value: [NSString stringWithFormat:@"%@",  [NSNumber numberWithInt:TimeSessionThird]]]];
    [fields addObject:[self getDictField:@"ScoreFaceDetect" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:scoreFacedetect]]]];
    [fields addObject:[self getDictField:@"DevicePitch" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:pitchAway]]]];
    [fields addObject:[self getDictField:@"DeviceRoll" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:rollAway]]]];
    [fields addObject:[self getDictField:@"DeviceYaw" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:yawAway]]]];
    [fields addObject:[self getDictField:@"DevicePitchClose" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:pitchClose]]]];
    [fields addObject:[self getDictField:@"DeviceRollClose" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:rollClose]]]];
    [fields addObject:[self getDictField:@"DeviceYawClose" value:[NSString stringWithFormat:@"%@",  [NSNumber numberWithDouble:yawClose]]]];
    [fields addObject:[self getDictField:@"DevicePitchInitial" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:pitchInitial]]]];
    [fields addObject:[self getDictField:@"DeviceRollInitial" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:rollInitial]]]];
    [fields addObject:[self getDictField:@"DeviceYawInitial" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:yawInitial]]]];
    [fields addObject:[self getDictField:@"DeviceLuminosity" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:luminosityAway]]]];
    [fields addObject:[self getDictField:@"DeviceLuminosityClose" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:luminosityClose]]]];
    
    NSDictionary *params = @{
        @"id" : strUuid,
        @"status" : status,
        @"fields": fields
    };

    //    Para logar o json
    //     NSString *jsonRequest = [self bv_jsonStringWithPrettyPrint:params];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/services/v3/AcessoService.svc/liveness/billing", self.URL] ];
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestMain:url params:params] completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
      
        if (data.length > 0 && error == nil)
        {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:NULL];
            NSString * string = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
                        
            self->billingId = strUuid;
            
            if(self.acessiBioManager.createProcess == nil || !self->_isFaceLiveness) {
                
              // NSString *baseWithBilling = [NSString stringWithFormat:@"data:%@/image/jpeg;base64,%@", self->billingId, self->base64ToUsage];
                
                LivenessXResult *livenessXResult = [LivenessXResult new];
                [livenessXResult setBase64:self->base64ToUsage];
                [livenessXResult setIsLiveness:self->_isFaceLiveness];
                [self.acessiBioManager onSuccesLivenessX:livenessXResult];
                
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                    //Background Thread
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        //Run UI Updates
                        [self doneProcess];
                    });
                });
                
            }else{
                [self createProcessV3];
            }
            
        }else {
        
            self->isRequestWebService = NO;

            if(self.debug) {
                NSLog(@"Error: %@", error);
            }
            NSData *data = [error.description dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if([json isKindOfClass:[NSDictionary class]]) {
                NSDictionary *error = [json valueForKey:@"Error"];
                NSString *description = [error valueForKey:@"Description"];
                [self.acessiBioManager onErrorLivenessX:[self strErrorFormatted:@"sendBillingV3" description:description]];
            }else{
                [self.acessiBioManager onErrorLivenessX:[self strErrorFormatted:@"sendBillingV3" description:@"Verifique sua url de conexão, apikey e token. Se persistir, entre em contato com a equipe da Acesso."]];
            }
            
            [self exitError];
        }
        
    }] resume];
    
}

#pragma mark - Liveness Request


-(void) sendLiveness  {
    
    isRequestWebService = YES;
    
    NSDictionary *dict = @{@"liveness" : [self getDictLiveness]};
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/services/v2/credService.svc/", urlDebug]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestMain:url params:dict] completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
      
        if (data.length > 0 && error == nil)
        {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:NULL];
           // NSString * string = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
                        
            if(self.debug) {
                NSLog(@"JSON: %@", response);
            }
            self->isRequestWebService = NO;
            
        }else {
        
            self->isRequestWebService = NO;
            
            if(self.debug) {
                NSLog(@"Error: %@", error);
            }
            
            NSData *data = [error.description dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if([json isKindOfClass:[NSDictionary class]]) {
                NSDictionary *error = [json valueForKey:@"Error"];
                NSString *description = [error valueForKey:@"Description"];
                
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ops"
                                                                                         message:description
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                //We add buttons to the alert controller by creating UIAlertActions:
                UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                    //                                                                    [self.view callFaceInsert];
                }];;
                [alertController addAction:actionOk];
                [self presentViewController:alertController animated:YES completion:nil];
                
            }
        }
        
    }] resume];
    
}


- (NSDictionary *)getDictLiveness{
    
    BOOL fotoboaCenter = [[dictLivenessResultCenter valueForKey:@"fotoboa"] boolValue];
    double confidenceCenter = [[dictLivenessResultCenter valueForKey:@"confidence"] doubleValue];
    
    BOOL fotoboaAway = [[dictLivenessResultAway valueForKey:@"fotoboa"] boolValue];
    double confidenceAway = [[dictLivenessResultAway valueForKey:@"confidence"] doubleValue];
    
    if(!fotoboaCenter) {
        if(confidenceCenter > 0.8) {
            confidenceCenter = 1 - confidenceCenter;
        }else{
            fotoboaCenter = YES;
        }
    }
    
    if(!fotoboaAway) {
        
        if(confidenceAway > 0.8) {
            confidenceAway = 1 - confidenceAway;
        }else{
            fotoboaAway = YES;
        }
        
    }
    
    if(self.base64AwayWithoutSmilling.length == 0) {
        self.base64AwayWithoutSmilling = self.base64Away;
    }
    
    NSDictionary *params = @{@"isLive": [NSNumber numberWithBool:self.isFaceLiveness],
                             @"Score": [NSNumber numberWithFloat:fTotal],
                             @"isLiveClose" : [NSNumber numberWithBool:fotoboaCenter],
                             @"ScoreClose" : [NSNumber numberWithDouble:confidenceCenter],
                             @"isLiveAway" : [NSNumber numberWithBool:fotoboaAway],
                             @"ScoreAway":[NSNumber numberWithDouble:confidenceAway],
                             @"IsBlinking" :  [NSNumber numberWithBool:self.isLivenessBlinking],
                             @"IsSmilling":  [NSNumber numberWithBool:self.isLivenessSmilling],
                             @"UserName": self.acessiBioManager.createProcess.name,
                             @"UserCPF": self.acessiBioManager.createProcess.code,
                             @"DeviceModel": [self deviceName],
                             @"Base64Center" : self.base64Center,
                             @"Base64Away" : self.base64AwayWithoutSmilling,
                             @"IsResetSession" :  [NSNumber numberWithBool:isResetSessionValidate],
                             @"AttemptsValidate" :  [NSNumber numberWithInt:attemptsValidate],
                             @"IsResetSessionSpoofing" :  [NSNumber numberWithBool:isResetSessionSpoofing],
                             @"AttemptsSpoofing" :  [NSNumber numberWithInt:attemptsSpoofing],
                             @"TimeTotal" : [NSNumber numberWithFloat:durationProcess],
                             @"Blinks" : [NSNumber numberWithInt:userBlinks],
                             @"TimeSmilling" : [NSNumber numberWithInt:timeToSmiling],
                             @"TimeSessionFirst" : [NSNumber numberWithFloat:TimeSessionFirst],
                             @"TimeSessionSecond" : [NSNumber numberWithInt:TimeSessionSecond],
                             @"TimeSessionThird" : [NSNumber numberWithInt:TimeSessionThird],
                             @"ScoreFaceDetect" : [NSNumber numberWithDouble:scoreFacedetect],
                             @"BiometryStatus" : [NSNumber numberWithInt:0],
                             @"BiometryMessage" : @"",
                             @"BiometryStatusAway" : [NSNumber numberWithInt:0],
                             @"BiometryMessageAway" : @"",
                             @"DevicePitch": [NSNumber numberWithDouble:pitchAway],
                             @"DeviceRoll" : [NSNumber numberWithDouble:rollAway],
                             @"DeviceYaw": [NSNumber numberWithDouble:yawAway],
                             @"DevicePitchClose": [NSNumber numberWithDouble:pitchClose],
                             @"DeviceRollClose": [NSNumber numberWithDouble:rollClose],
                             @"DeviceYawClose": [NSNumber numberWithDouble:yawClose],
                             @"DevicePitchInitial": [NSNumber numberWithDouble:pitchInitial],
                             @"DeviceRollInitial": [NSNumber numberWithDouble:rollInitial],
                             @"DeviceYawInitial": [NSNumber numberWithDouble:yawInitial],
                             @"DeviceLuminosity" :[NSNumber numberWithDouble:luminosityAway],
                             @"DeviceLuminosityClose": [NSNumber numberWithDouble:luminosityClose],
    };
    
    
    return params;
    
}

- (NSMutableURLRequest *)getRequestMain: (NSURL *)url params:(NSDictionary *)params {
    NSError *error;
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:self.APIKEY forHTTPHeaderField:@"APIKEY"];
    [request addValue:self.TOKEN forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error]];
    return request;
}

-(NSString*) bv_jsonStringWithPrettyPrint: (NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    }
    return  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
}

- (NSDictionary *)getDictField: (NSString *)key value: (id)value {
    return @{@"key": key, @"value": value};
}

#pragma mark - Create Process v3

- (void)createProcessV3 {
    
    isRequestWebService = YES;
    
    NSString *baseWithBilling = [NSString stringWithFormat:@"data:%@/image/jpeg;base64,%@", billingId, base64ToUsage];
    
    NSDictionary *dict = @{
        @"subject" : @{@"Code": self.acessiBioManager.createProcess.code, @"Name":self.acessiBioManager.createProcess.name },
        @"onlySelfie" : [NSNumber numberWithBool:YES],
        @"imagebase64": baseWithBilling
    };
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/services/v3/AcessoService.svc/processes", self.URL]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestMain:url params:dict] completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
      
        if (data.length > 0 && error == nil)
        {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:NULL];
            NSDictionary *result = response;
            self->processId = [result valueForKey:@"Id"];
            
            if(isDebug) {
                [self sendLiveness];
            }
            
            self->livenessXResult = [LivenessXResult new];
            [self->livenessXResult setBase64:self->base64ToUsage];
            [self->livenessXResult setIsLiveness:self->_isFaceLiveness];
            [self->livenessXResult setProcessId:self->processId];
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self doneProcess];
                });
            });
            
        }else {
         
            if(self.debug) {
                NSLog(@"Error: %@", error);
            }
            self->isRequestWebService = NO;
            
            NSData *data = [error.description dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if([json isKindOfClass:[NSDictionary class]]) {
                NSDictionary *error = [json valueForKey:@"Error"];
                NSString *description = [error valueForKey:@"Description"];
                [self.acessiBioManager onErrorLivenessX:[self strErrorFormatted:@"createProcessV3" description:description]];
            }else{
                [self.acessiBioManager onErrorLivenessX:[self strErrorFormatted:@"createProcessV3" description:@"Verifique sua url de conexão, apikey e token. Se persistir, entre em contato com a equipe da Acesso."]];
            }
            
            [self exitError];
            
        }
        
    }] resume];
    
}

#pragma mark - Sensors

- (void)sensors {
    [self gyroscope];
}

- (void)gyroscope {
    
    if(isValidating) {
        return;
    }
    
    self.motionManager = [[CMMotionManager alloc] init];
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical
                                                            toQueue:[NSOperationQueue currentQueue]
                                                        withHandler:^(CMDeviceMotion *motion, NSError *error)
     {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            /*
             CGFloat x = motion.gravity.x;
             CGFloat y = motion.gravity.y;
             CGFloat z = motion.gravity.z;
             */
            
            if(self.motionManager.deviceMotion != nil) {
                
                CMQuaternion quat = self.motionManager.deviceMotion.attitude.quaternion;
                
                double yaw = asin(2*(quat.x*quat.z - quat.w*quat.y));
                double pitch = RADIANS_TO_DEGREES(atan2(2*(quat.x*quat.w + quat.y*quat.z), 1 - 2*quat.x*quat.x - 2*quat.z*quat.z));
                double roll = RADIANS_TO_DEGREES(atan2(2*(quat.y*quat.w - quat.x*quat.z), 1 - 2*quat.y*quat.y - 2*quat.z*quat.z)) ;
                
                pitch = pitch - 90;
                
                self->pPitch = pitch;
                self->pRoll = roll;
                self->pYaw = yaw;
                
                //NSLog(@"%f", yaw);
                
                if(self->pitchInitial == 0) {
                    self->pitchInitial = pitch;
                    self->rollInitial = roll;
                    self->yawInitial = yaw;
                }
                
            }
            
            
        }];
    }];
    
}

- (void)luminosity:(CMSampleBufferRef)sampleBuffer {
    
    if(isValidating) {
        return;
    }
    
    if(!isStartLuminositySensor) {
        isStartLuminositySensor = YES;
        
        CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,
                                                                     sampleBuffer, kCMAttachmentMode_ShouldPropagate);
        NSDictionary *metadata = [[NSMutableDictionary alloc]
                                  initWithDictionary:(__bridge NSDictionary*)metadataDict];
        CFRelease(metadataDict);
        NSDictionary *exifMetadata = [[metadata
                                       objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
        float brightnessValue = [[exifMetadata
                                  objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
        
        luminosity = brightnessValue;
        
    }
    
    
}

/*
 
 BOOL isDarkImage(UIImage* inputImage){
 
 
 BOOL isDark = FALSE;
 
 CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(inputImage.CGImage));
 const UInt8 *pixels = CFDataGetBytePtr(imageData);
 
 int darkPixels = 0;
 
 int length = CFDataGetLength(imageData);
 int const darkPixelThreshold = (inputImage.size.width*inputImage.size.height)*.65;
 
 for(int i=0; i<length; i+=4)
 {
 int r = pixels[i];
 int g = pixels[i+1];
 int b = pixels[i+2];
 
 //luminance calculation gives more weight to r and b for human eyes
 float luminance = (0.299*r + 0.587*g + 0.114*b);
 if (luminance<150) darkPixels ++;
 }
 
 if (darkPixels >= darkPixelThreshold)
 isDark = YES;
 
 CFRelease(imageData);
 
 return isDark;
 
 }
 */


- (UIImage *)croppIngimage:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}


#pragma mark - Popup's

- (void)popupShow {
    
    isPopUpShow = YES;
    
    [vAlert setHidden:YES];
    [self removeFlash];
    
    [self addVHole:CGRectZero];
    
    popup = [[PopUpValidationLiveness alloc]initWithFrame:CGRectMake(((SCREEN_WIDTH/2) - 165), ((SCREEN_HEIGHT/2) - 265) , 330, 530)];
    [popup setType:PopupTypeGeneric faceInsertView:self];
    
    UIColor *colorBackgroundPopup = [UIColor whiteColor];
    if(self.colorBackgroundPopupError != nil) {
        colorBackgroundPopup = self.colorBackgroundPopupError;
    }
    [popup setBackgroundColor:colorBackgroundPopup];
    
    UIColor *colorBackgroundButtonPopupError = [UIColor colorWithRed:41.0f/255.0f green:128.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    if(self.colorBackgroundButtonPopupError != nil) {
        colorBackgroundButtonPopupError = self.colorBackgroundButtonPopupError;
    }
    [popup setBackgroundColorButton:colorBackgroundButtonPopupError];
    
    UIColor *colorTitleButtonPopupError = [UIColor whiteColor];
    if(self.colorTitleButtonPopupError != nil) {
        colorTitleButtonPopupError = self.colorTitleButtonPopupError;
    }
    [popup setTitleColorButton:colorTitleButtonPopupError];
    
    if(self.imageIconPopupError != nil) {
        [popup setImageIconPopupError:self.imageIconPopupError];
    }
    
    [self.view addSubview:popup];
    
}

- (void)popupHidden {
    
    isPopUpShow = NO;
    
    [self changeHoleView:frameCurrent delayInSeconds:0];
    
    [popup removeFromSuperview];
    popup = nil;
    
}

#pragma mark - General

-(NSString*) deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

- (UIColor *)getColorPrimary {
    return [UIColor colorWithRed:41.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1.0];
}


- (UIColor *)getColorGreen {
    return [UIColor colorWithRed:59.0f/255.0f green:200.0f/255.0f blue:47.0f/255.0f alpha:1.0];
}


- (UIImage *)blurredImageWithImage:(UIImage *)sourceImage{
    
    //  Create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    
    //  Setting up Gaussian Blur
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    /*  CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches
     *  up exactly to the bounds of our original image */
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *retVal = [UIImage imageWithCGImage:cgImage];
    
    if (cgImage) {
        CGImageRelease(cgImage);
    }
    
    return retVal;
}

- (NSString *)strErrorFormatted: (NSString *)method description: (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@", method, description];
}

@end
