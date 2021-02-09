//
//  UIViewWithHole.m
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 29/10/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import "UIViewWithHole.h"
#import "UIColorExtensions.h"

@implementation UIViewWithHole

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor*)color andTransparentRect:(CGRect)rect cornerRadius: (CGFloat)radius
{
    backgroundColor = color;
    rectTransparent = rect;
    cornerRadius = radius;
    
    [self initAnimation];
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    context = UIGraphicsGetCurrentContext();
    // Clear any existing drawing on this view
    // Remove this if the hole never changes on redraws of the UIView
    CGContextClearRect(context, self.bounds);
    
    // Create a path around the entire view
    clipPath = [UIBezierPath bezierPathWithRect:self.bounds];
    
    // Your transparent window. This is for reference, but set this either as a property of the class or some other way
    CGRect transparentFrame = rectTransparent;
    // Add the transparent window
    
    [self startAnimation:[self samplePath:transparentFrame]];
    [clipPath appendPath:[self samplePath:transparentFrame]];
    
    // NOTE: If you want to add more holes, simply create another UIBezierPath and call [clipPath appendPath:anotherPath];
    
    // This sets the algorithm used to determine what gets filled and what doesn't
    clipPath.usesEvenOddFillRule = YES;
    // Add the clipping to the graphics context
    [clipPath addClip];
    
    // set your color
    UIColor *tintColor = backgroundColor;
    
    // (optional) set transparency alpha
    CGContextSetAlpha(context, 1.0f);
    // tell the color to be a fill color
    [tintColor setFill];
    // fill the path
    [clipPath fill];
    
    
}

- (void)movePath {
    
    [clipPath removeAllPoints];
    
    /*
    // example path
    clipPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 100, 100)];
    
    // scale it
    CGFloat scale = 0.9;
    [clipPath applyTransform:CGAffineTransformMakeScale(scale, scale)];

    // move it
    CGSize translation = CGSizeMake(10, 5);
    [clipPath applyTransform:CGAffineTransformMakeTranslation(translation.width,
                                                          translation.height)];

//    // apply it
//    self.myLayer.path = clipPath;
    
    */
}

- (UIBezierPath *)samplePath : (CGRect)transparentFrame
{
    return [UIBezierPath bezierPathWithRoundedRect:transparentFrame cornerRadius:(transparentFrame.size.width/2)];
}

- (void)initAnimation {
    CGRect rectSuccess = CGRectMake(rectTransparent.origin.x + 10, rectTransparent.origin.y + 10, rectTransparent.size.width - 20, rectTransparent.size.height - 20);
    
    shapeLayerSuccess = [CAShapeLayer layer];
    shapeLayerSuccess.path = [[self samplePath:rectSuccess] CGPath];
    shapeLayerSuccess.strokeColor = [[UIColor colorWithRed:41.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:0.7] CGColor];
    shapeLayerSuccess.fillColor = nil;
    shapeLayerSuccess.lineWidth = 7.5f;
    shapeLayerSuccess.lineJoin = kCALineJoinBevel;
}

- (void)startAnimationSuccess
{
    
    if(shapeLayerSuccess == nil) {
        [self initAnimation];
    }
    

    [self.layer addSublayer:shapeLayerSuccess];

    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 0.5f;
    pathAnimation.fromValue = @(0.0f);
    pathAnimation.toValue = @(1.0f);
    
    [shapeLayerSuccess addAnimation:pathAnimation forKey:@"strokeEnd"];
    

}


- (void)startAnimationError
{
    
    [shapeLayerSuccess removeAllAnimations];
    
    [self.layer addSublayer:shapeLayerSuccess];
    
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            [self->shapeLayerSuccess removeFromSuperlayer];
        }];
        
        CABasicAnimation *pathAnimationReverse = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
             pathAnimationReverse.duration = 1.5;
             pathAnimationReverse.fromValue = @(1.0f);
             pathAnimationReverse.toValue = @(0.0f);
             shapeLayerSuccess.strokeColor = [[UIColor colorWithRed:41.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:0.7] CGColor];
             [shapeLayerSuccess addAnimation:pathAnimationReverse forKey:@"strokeEnd"];

        
    } [CATransaction commit];
    
}


- (void)startAnimation: (UIBezierPath *)path
{
    
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.path = [path CGPath];
    self.shapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
    self.shapeLayer.fillColor = nil;
    self.shapeLayer.lineWidth = 5.5f;
    self.shapeLayer.lineJoin = kCALineJoinBevel;
    
    [self.layer addSublayer:self.shapeLayer];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1.0;
    pathAnimation.fromValue = @(0.0f);
    pathAnimation.toValue = @(1.0f);
    

    [self.shapeLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
}


@end
