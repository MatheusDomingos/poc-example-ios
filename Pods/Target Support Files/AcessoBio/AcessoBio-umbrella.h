#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AcessoBio.h"
#import "AcessoBioManager.h"
#import "CameraDocumentResult.h"
#import "CameraFaceResult.h"
#import "CameraFaceView.h"
#import "CameraMain.h"
#import "CreateProcess.h"
#import "DocumentInsertView.h"
#import "FacematchResult.h"
#import "FixedValues.h"
#import "LivenessXResult.h"
#import "LivenessXView.h"
#import "OCRResult.h"
#import "PopUpValidationLiveness.h"
#import "UIColorExtensions.h"
#import "UIImageUtils.h"
#import "UIViewWithHole.h"
#import "ValidateLiveness.h"

FOUNDATION_EXPORT double AcessoBioVersionNumber;
FOUNDATION_EXPORT const unsigned char AcessoBioVersionString[];

