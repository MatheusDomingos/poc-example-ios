//
//  CameraBio.h
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 13/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LivenessXResult.h"
#import "CameraFaceResult.h"
#import "CameraDocumentResult.h"
#import "OCRResult.h"
#import "FacematchResult.h"
#import "CreateProcess.h"
#import "CreateProcess.h"

@class LivenessXView;
@class CameraFaceView;
@class DocumentInsertView;

typedef NS_ENUM(NSInteger, DocumentType) {
    DocumentNone,
    DocumentCNH,
    DocumentRG,
    DocumentRGFrente,
    DocumentRGVerso
};

@protocol AcessoBioDelegate <NSObject>

@optional
- (BOOL)cameraBioShouldAutoCapture;
- (BOOL)cameraBioShouldCountdow;

- (void)onSuccesCameraDocument: (CameraDocumentResult *)result;
- (void)onErrorCameraDocument: (NSString *)error;

- (void)onSuccessOCR: (OCRResult *)result;
- (void)onErrorOCR: (NSString *)error;

- (void)onSuccessFacematch: (FacematchResult *)result;
- (void)onErrorFacematch: (NSString *)error;

- (void)onSuccessFacesCompare:(BOOL)status;
- (void)onErrorFacesCompare:(NSString *)error;

@required
- (void)onSuccesLivenessX: (LivenessXResult *)result;
- (void)onErrorLivenessX: (NSString *)error;

- (void)onSuccesCameraFace: (CameraFaceResult *)result;
- (void)onErrorCameraFace: (NSString *)error;

@end

@interface AcessoBioManager : NSObject  <AcessoBioDelegate>{
    UIViewController *viewController;
    
    LivenessXView *lView;
    CameraFaceView *cView;
    DocumentInsertView *dView;
    
    NSString *url;
    NSString *apikey;
    NSString *token;
    
    BOOL isAutoCapture;
    BOOL isSmartCamera;
    
    BOOL isFacematchProcess;
    
    DocumentType documentTypeFacematch;
    NSString * base64Facematch;
    
    UIColor *colorSilhoutteNeutral;
    UIColor *colorSilhoutteSuccess;
    UIColor *colorSilhoutteError;
    UIColor *colorBackground;
    UIColor *colorBackgroundBoxStatus;
    UIColor *colorTextBoxStatus;
    UIColor *colorBackgroundPopupError;
    UIColor *colorTextPopupError;
    UIColor *colorBackgroundButtonPopupError;
    UIColor *colorTitleButtonPopupError;
    UIImage *imageIconPopupError;
    
}

@property (nonatomic, weak) id <AcessoBioDelegate> delegate;

@property (nonatomic, strong) CreateProcess *createProcess;

#pragma mark - Instance
- (id)initWithViewController:(id)view url:(NSString*)url apikey: (NSString*)apikey token: (NSString*)token;

#pragma mark - Custom

- (void)disableAutoCapture;
- (void)disableSmartCamera;

- (void)enableAutoCapture;
- (void)enableSmartCamera;

- (void)setColorSilhoutteNeutral: (UIColor *)color;
- (void)setColorSilhoutteSuccess: (UIColor *)color;
- (void)setColorSilhoutteError: (UIColor *)color;
- (void)setColorBackground: (UIColor *)color;
- (void)setColorBackgroundBoxStatus: (UIColor *)color;
- (void)setColorTextBoxStatus: (UIColor *)color;
- (void)setColorBackgroundPopupError: (UIColor *)color;
- (void)setColorTextPopupError: (UIColor *)color;
- (void)setColorBackgroundButtonPopupError : (UIColor *)color;
- (void)setColorTitleButtonPopupError : (UIColor *)color;
- (void)setImageIconPopupError: (UIImage *)image; 

#pragma mark - Camera

- (void)openLivenessX;
- (void)openLivenessXWithCreateProcess: (NSString *)code name:(NSString *) name;
- (void)openLivenessXWithCreateProcess: (NSString *)code name:(NSString *) name gender: (NSString *)gender birthdate: (NSString *)birthdate email: (NSString *)email phone : (NSString *)phone;

- (void)openCameraFace;
- (void)openCameraFaceWithCreateProcess: (NSString *)code name:(NSString *) name;
- (void)openCameraFaceWithCreateProcess: (NSString *)code name:(NSString *) name gender: (NSString *)gender birthdate: (NSString *)birthdate email: (NSString *)email phone : (NSString *)phone;

- (void)openCameraDocuments : (DocumentType) documentType;
- (void)openCameraDocumentOCR : (DocumentType) documentType;
- (void)onErrorCameraDocument: (NSString *)error;
- (void)openCameraDocumentFacematch : (DocumentType) documentType;

- (void)facesCompare: (NSString *)cpf;

#pragma mark - Callbacks
- (void)onSuccesLivenessX: (LivenessXResult *)base64;
-(void)onErrorLivenessX: (NSString *)error;
- (void)onSuccesCameraFace: (CameraFaceResult *)result;
- (void)onErrorCameraFace: (NSString *)error;



@end

