//
//  PopUpValidationLiveness.h
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 31/03/20.
//  Copyright © 2020 Matheus  domingos. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LivenessXView;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PopupType) {
  PopupTypeFaceError,
  PopupTypeLightError,
    PopupTypeGeneric
};

@interface PopUpValidationLiveness : UIView {
    PopupType popupType;
    LivenessXView *pFaceInsertView;
    UIButton *btTryAgain;
    UIColor *colorButtonPopupError;
    UIImageView *iconPopupError;
    float baseValue;
}

- (id)initWithType : (PopupType) pPopupType faceInsertView : (LivenessXView *)faceInsertView;
- (void)setType : (PopupType) pPopupType faceInsertView : (LivenessXView *)faceInsertView;

- (void)setBackgroundColorButton : (UIColor *)color;
- (void)setTitleColorButton : (UIColor *)color;
- (void)setImageIconPopupError : (UIImage *)image;

@end

NS_ASSUME_NONNULL_END
