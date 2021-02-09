//
//  CameraBio.m
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 13/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//
#import "AcessoBioManager.h"
#import "LivenessXView.h"
#import "CameraFaceView.h"
#import "DocumentInsertView.h"

@implementation AcessoBioManager

- (id)initWithViewController:(id)view url:(NSString *)pUrl apikey:(NSString *)pApikey token:(NSString *)pToken
{
    
    self = [super init];
    if(self) {
        viewController = view;
        self.delegate = view;
        url = pUrl;
        apikey = pApikey;
        token = pToken;
        isAutoCapture = YES;
        isSmartCamera = YES;
    }
    
    return self;
    
}

#pragma mark - Custom

- (void)disableAutoCapture {
    isAutoCapture = NO;
}

- (void)disableSmartCamera {
    isSmartCamera = NO;
}

- (void)enableAutoCapture {
    isAutoCapture = YES;
}

- (void)enableSmartCamera {
    isSmartCamera = YES;
}

- (void)setColorSilhoutteNeutral: (UIColor *)color {
    colorSilhoutteNeutral = color;
}

- (void)setColorSilhoutteSuccess: (UIColor *)color {
    colorSilhoutteSuccess = color;

}

- (void)setColorSilhoutteError: (UIColor *)color {
    colorSilhoutteError = color;
}

- (void)setColorBackground: (UIColor *)color {
    colorBackground = color;
}

- (void)setColorBackgroundBoxStatus: (UIColor *)color {
    colorBackgroundBoxStatus = color;
}

- (void)setColorTextBoxStatus: (UIColor *)color {
    colorTextBoxStatus = color;
}

- (void)setColorBackgroundPopupError: (UIColor *)color {
    colorBackgroundPopupError = color;
}

- (void)setColorTextPopupError: (UIColor *)color {
    colorTextPopupError = color;
}

- (void)setColorBackgroundButtonPopupError:(UIColor *)color {
    colorBackgroundButtonPopupError = color;
}

- (void)setColorTitleButtonPopupError:(UIColor *)color {
    colorTitleButtonPopupError = color;
}

- (void)setImageIconPopupError: (UIImage *)image {
    imageIconPopupError = image;
}

#pragma mark - Cameras

- (void)openLivenessX {
    
    if ([self verifyTarget]) {
        [self callLivenessXView];
    }
    
}

- (void)openLivenessXWithCreateProcess: (NSString *)code name:(NSString *) name {
    
    [self openLivenessXWithCreateProcess:code name:name gender:nil birthdate:nil email:nil phone:nil];
    
}

- (void)openLivenessXWithCreateProcess: (NSString *)code name:(NSString *) name gender: (NSString *)gender birthdate: (NSString *)birthdate email: (NSString *)email phone : (NSString *)phone {
    
    if ([self verifyTarget]) {
        
        CreateProcess *objProcess = [CreateProcess new];
        objProcess.code = code;
        objProcess.name = name;
        
        if(gender != nil) {
            objProcess.gender = gender;
        }
        
        if(birthdate != nil) {
            objProcess.birthdate = birthdate;
        }
        
        if(email != nil) {
            objProcess.email = email;
        }
        
        if(phone != nil) {
            objProcess.phone = phone;
        }
        
        self.createProcess = objProcess;
    
        [self callLivenessXView];
        
    }
    
}

- (void)openCameraFace {
    
    if ([self verifyTarget]) {
        
        cView = [CameraFaceView new];
        [cView setAcessiBioManager:self];
        [cView setURL:url];
        [cView setAPIKEY:apikey];
        [cView setTOKEN:token];
        [cView setIsEnableAutoCapture:isAutoCapture];
        [cView setIsEnableSmartCapture:isSmartCamera];
        [cView setColorSilhoutteNeutral:colorSilhoutteNeutral];
        [cView setColorSilhoutteError:colorSilhoutteError];
        [cView setColorSilhoutteSuccess:colorSilhoutteSuccess];
        [cView setColorBackground:colorBackground];
        [cView setColorBackgroundBoxStatus:colorBackgroundBoxStatus];
        [cView setColorTextBoxStatus:colorTextBoxStatus];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:cView];
        [nav setNavigationBarHidden:YES animated:NO];
        [nav setModalPresentationStyle:UIModalPresentationFullScreen];
        [viewController presentViewController:nav animated:YES completion:nil];
        
    }
    
}

- (void)openCameraFaceWithCreateProcess: (NSString *)code name:(NSString *) name {
    
    if ([self verifyTarget]) {
        
        CreateProcess *objProcess = [CreateProcess new];
        objProcess.code = code;
        objProcess.name = name;
        
        self.createProcess = objProcess;
        
        cView = [CameraFaceView new];
        [cView setAcessiBioManager:self];
        [cView setURL:url];
        [cView setAPIKEY:apikey];
        [cView setTOKEN:token];
        [cView setIsEnableAutoCapture:isAutoCapture];
        [cView setIsEnableSmartCapture:isSmartCamera];
        [cView setColorSilhoutteNeutral:colorSilhoutteNeutral];
        [cView setColorSilhoutteError:colorSilhoutteError];
        [cView setColorSilhoutteSuccess:colorSilhoutteSuccess];
        [cView setColorBackground:colorBackground];
        [cView setColorBackgroundBoxStatus:colorBackgroundBoxStatus];
        [cView setColorTextBoxStatus:colorTextBoxStatus];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:cView];
        [nav setNavigationBarHidden:YES animated:NO];
        [nav setModalPresentationStyle:UIModalPresentationFullScreen];
        [viewController presentViewController:nav animated:YES completion:nil];
        
    }
    
}

- (void)openCameraFaceWithCreateProcess: (NSString *)code name:(NSString *) name gender: (NSString *)gender birthdate: (NSString *)birthdate email: (NSString *)email phone : (NSString *)phone {
    
    if ([self verifyTarget]) {
        
        CreateProcess *objProcess = [CreateProcess new];
        objProcess.code = code;
        objProcess.name = name;
        objProcess.gender = gender;
        objProcess.birthdate = birthdate;
        objProcess.email = email;
        objProcess.phone = phone;
        
        self.createProcess = objProcess;
        
        cView = [CameraFaceView new];
        [cView setAcessiBioManager:self];
        [cView setURL:url];
        [cView setAPIKEY:apikey];
        [cView setTOKEN:token];
        [cView setIsEnableAutoCapture:isAutoCapture];
        [cView setIsEnableSmartCapture:isSmartCamera];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:cView];
        [nav setNavigationBarHidden:YES animated:NO];
        [nav setModalPresentationStyle:UIModalPresentationFullScreen];
        [viewController presentViewController:nav animated:YES completion:nil];
        
    }
    
}

- (void)openCameraDocuments : (DocumentType) documentType {
    
    dView = [DocumentInsertView new];
    
    if(documentType == DocumentCNH) {
        dView.type = 4;
    }else if(documentType == DocumentRGFrente || documentType == DocumentRG) {
        dView.type = 501;
    }else if(documentType == DocumentRGVerso){
        dView.type = 502;
    }else{
        dView.type = 999;
    }
    
    dView.acessoBioManager = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:dView];
    [nav setNavigationBarHidden:YES animated:NO];
    [nav setModalPresentationStyle:UIModalPresentationFullScreen];
    [viewController presentViewController:nav animated:YES completion:nil];
    
}

- (void)openCameraDocumentOCR : (DocumentType) documentType {
    
    dView = [DocumentInsertView new];
    
    [dView setAcessoBioManager:self];
    [dView setURL:url];
    [dView setAPIKEY:apikey];
    [dView setTOKEN:token];
    [dView setOperationType:OCR];
    
    if(documentType == DocumentCNH) {
        dView.type = 4;
    }else if(documentType == DocumentRGFrente || documentType == DocumentRG) {
        dView.type = 501;
    }else if(documentType == DocumentRGVerso){
        dView.type = 502;
    }else{
        dView.type = 999;
    }
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:dView];
    [nav setNavigationBarHidden:YES animated:NO];
    [nav setModalPresentationStyle:UIModalPresentationFullScreen];
    [viewController presentViewController:nav animated:YES completion:nil];
    
}

- (void)openCameraDocumentFacematch : (DocumentType) documentType {
    
    isFacematchProcess = YES;
    documentTypeFacematch = documentType;
    
    [self openCameraFace];
    
}

- (void)openDocumentFaceMatch {
    
    dView = [DocumentInsertView new];
    
    [dView setAcessoBioManager:self];
    [dView setURL:url];
    [dView setAPIKEY:apikey];
    [dView setTOKEN:token];
    [dView setBase64SelfieToFaceMatch:base64Facematch];
    [dView setOperationType:Facematch];
    
    if(documentTypeFacematch == DocumentCNH) {
        dView.type = 4;
    }else if(documentTypeFacematch == DocumentRGFrente || documentTypeFacematch == DocumentRG) {
        dView.type = 501;
    }else if(documentTypeFacematch == DocumentRGVerso){
        dView.type = 502;
    }else{
        dView.type = 999;
    }
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:dView];
    [nav setNavigationBarHidden:YES animated:NO];
    [nav setModalPresentationStyle:UIModalPresentationFullScreen];
    [viewController presentViewController:nav animated:YES completion:nil];
    
}

- (void)facesCompare: (NSString *)cpf{
    
    cView = [CameraFaceView new];
    [cView setAcessiBioManager:self];
    [cView setURL:url];
    [cView setAPIKEY:apikey];
    [cView setTOKEN:token];
    [cView setIsEnableAutoCapture:isAutoCapture];
    [cView setIsEnableSmartCapture:isSmartCamera];
    [cView setIsFacesCompareOneToOne:YES];
    [cView setCpfToFacesCompare:cpf];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:cView];
    [nav setNavigationBarHidden:YES animated:NO];
    [nav setModalPresentationStyle:UIModalPresentationFullScreen];
    [viewController presentViewController:nav animated:YES completion:nil];
    
}

#pragma mark - Instances
- (void)callLivenessXView {
    
    lView = [LivenessXView new];
    [lView setAcessiBioManager:self];
    [lView setURL:url];
    [lView setAPIKEY:apikey];
    [lView setTOKEN:token];
    [lView setColorSilhoutteNeutral:colorSilhoutteNeutral];
    [lView setColorSilhoutteError:colorSilhoutteError];
    [lView setColorSilhoutteSuccess:colorSilhoutteSuccess];
    [lView setColorBackground:colorBackground];
    [lView setColorBackgroundBoxStatus:colorBackgroundBoxStatus];
    [lView setColorTextBoxStatus:colorTextBoxStatus];
    [lView setColorBackgroundPopupError:colorBackgroundPopupError];
    [lView setColorTextPopupError:colorTextPopupError];
    [lView setColorBackgroundButtonPopupError:colorBackgroundButtonPopupError];
    [lView setColorTitleButtonPopupError:colorTitleButtonPopupError];
    [lView setImageIconPopupError:imageIconPopupError];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:lView];
    [nav setNavigationBarHidden:YES animated:NO];
    [nav setModalPresentationStyle:UIModalPresentationFullScreen];
    [viewController presentViewController:nav animated:YES completion:nil];
    
}

#pragma mark - Utils

- (BOOL)verifyTarget {
    
    if (@available(iOS 11.0, *)) {
        return YES;
    }else{
        [self onErrorLivenessX:@"Este método está disponível a partir do iOS 11."];
        return NO;
    }
}

#pragma mark - Callbacks

- (void)onSuccesLivenessX: (LivenessXResult *)result {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSuccesLivenessX:)]) {
        [self.delegate onSuccesLivenessX:result];
    }else{
        NSLog(@"Método onSuccesLivenessX não implementado. Implemente-o e tente novamente...");
    }
    
}

- (void)onErrorLivenessX:(NSString *)error {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onErrorLivenessX:)]) {
        [self.delegate onErrorLivenessX:error];
    }else{
        NSLog(@"Método onErrorLivenessX não implementado. Implemente-o e tente novamente...");
    }
    
}

- (void)onSuccesCameraFace:(CameraFaceResult *)result {
    
    if(isFacematchProcess){
        
        isFacematchProcess = NO;
        base64Facematch = result.base64;
        
        [self performSelector:@selector(openDocumentFaceMatch) withObject:nil afterDelay:0.5];
        
    }else if (self.delegate && [self.delegate respondsToSelector:@selector(onSuccesCameraFace:)]) {
        [self.delegate onSuccesCameraFace:result];
    }else{
        NSLog(@"Método onSuccesCameraFace não implementado. Implemente-o e tente novamente...");
    }
    
}

- (void)onErrorCameraFace:(NSString *)error {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onErrorCameraFace:)]) {
        [self.delegate onErrorCameraFace:error];
    }else{
        NSLog(@"Método onErrorCameraFace não implementado. Implemente-o e tente novamente...");
    }
    
}

- (void)onSuccesCameraDocument: (CameraDocumentResult *)result{
    
    if(dView.type == 501) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onSuccesCameraDocument:)]) {
            [self.delegate onSuccesCameraDocument:result];
        }
        
        [self openCameraDocuments:DocumentRGVerso];
        
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(onSuccesCameraDocument:)]) {
            [self.delegate onSuccesCameraDocument:result];
        }
    }
    
}

- (void)onErrorCameraDocument:(NSString *)error{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onErrorCameraDocument:)]) {
        [self.delegate onErrorCameraDocument:error];
    }else{
        NSLog(@"Método onErrorCameraDocument não implementado. Implemente-o e tente novamente...");
    }
    
}

- (void)onSuccessOCR: (OCRResult *)result{
    
    if(dView.type == 501) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onSuccessOCR:)]) {
            [self.delegate onSuccessOCR:result];
        }
        
        [self openCameraDocuments:DocumentRGVerso];
        
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(onSuccessOCR:)]) {
            [self.delegate onSuccessOCR:result];
        }
    }
    
}

- (void)onErrorOCR: (NSString *)error {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onErrorOCR:)]) {
        [self.delegate onErrorOCR:error];
    }else{
        NSLog(@"Método onErrorFacesCompare não implementado. Implemente-o e tente novamente...");
    }
    
}

- (void)onSuccessFacematch: (FacematchResult *)result {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSuccessFacematch:)]) {
        [self.delegate onSuccessFacematch:result];
    }
    
}

- (void)onErrorFacematch: (NSString *)error {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onErrorFacematch:)]) {
        [self.delegate onErrorFacematch:error];
    }else{
        NSLog(@"Método onErrorFacesCompare não implementado. Implemente-o e tente novamente...");
    }
    
}

- (void)onSuccessFacesCompare:(BOOL)status {
    
        if (self.delegate && [self.delegate respondsToSelector:@selector(onSuccessFacesCompare:)]) {
            [self.delegate onSuccessFacesCompare:status];
        }
    
}

- (void)onErrorFacesCompare:(NSString *)error {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onErrorFacesCompare:)]) {
        [self.delegate onErrorFacesCompare:error];
    }else{
        NSLog(@"Método onErrorFacesCompare não implementado. Implemente-o e tente novamente...");
    }
    
}

@end
