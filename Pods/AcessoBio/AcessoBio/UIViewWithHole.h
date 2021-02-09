//
//  UIViewWithHole.h
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 29/10/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewWithHole : UIView {
    CGRect rectTransparent;
    UIColor *backgroundColor;
    CGFloat cornerRadius;
    CAShapeLayer *shapeLayerSuccess;
    
    UIBezierPath *clipPath;
    CGContextRef context;
}


@property (strong, nonatomic)  CAShapeLayer *shapeLayer;

- (void)startAnimationSuccess;
- (void)startAnimationError;

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor*)color andTransparentRect:(CGRect)rect cornerRadius: (CGFloat)radius;

@end

NS_ASSUME_NONNULL_END
