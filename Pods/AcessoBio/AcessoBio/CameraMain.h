//
//  CameraMain.h
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 20/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>

#define NAME_APPLICATION [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define TAB_HEIGHT self.tabBarController.tabBar.frame.size.height

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)

#define PLATAFORM = [[[UIDevice currentDevice] systemVersion] intValue];

NS_ASSUME_NONNULL_BEGIN


@interface CameraMain : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate> {
    
    AVCaptureVideoPreviewLayer *previewLayer;

    
}


@property (nonatomic, strong) UIButton *btTakePic;

@property (nonatomic) AVCaptureDevicePosition defaultCamera;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) AVCaptureVideoDataOutput *dataOutput;
@property (nonatomic, assign) id delegate;
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) NSLock *renderLock;
@property (nonatomic) CIImage *latestFrame;

- (AVCaptureDevice *) deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position;

- (AVCaptureVideoOrientation) getCurrentOrientation;

- (void) updateOrientation:(AVCaptureVideoOrientation)orientation;

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position;

- (UIImage *)converCIImageToUIImage : (CIImage *)cIImage;

- (float)normalizeXPoint : (float)point faceWidth:(float)faceWidth;
- (float)normalizeYPoint : (float)point faceHeight:(float)faceHeight;

- (void) setupCamera:(BOOL) isSelfie;

- (void) startCamera;
- (void) stopCamera;

- (UIColor *)getColorPrimary;


@end

NS_ASSUME_NONNULL_END
