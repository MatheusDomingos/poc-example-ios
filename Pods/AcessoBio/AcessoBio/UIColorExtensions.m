//
//  UIColorExtensions.m
//  e-camaleao
//
//  Created by Matheus Domingos on 12/03/18.
//  Copyright © 2018 Matheus Domingos. All rights reserved.
//

#import "UIColorExtensions.h"

@implementation UIColor (UIColorExtensions)

- (UIColor *)bioPrimary {
    return [UIColor colorWithRed:41.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1.0];
}

- (UIColor *)bioGreen {
    return [UIColor colorWithRed:208.0/255.0 green:185.0/255.0 blue:49.0/255.0 alpha:1.0];
}

+ (UIColor *)remateTabIconSelected {
    return [UIColor colorWithRed:26.0/255.0 green:107.0/255.0 blue:144.0/255.0 alpha:1.0];
}


+ (UIColor *)remateYellows {
    return [UIColor colorWithRed:240.0/255.0 green:205.0/255.0 blue:29.0/255.0 alpha:1.0];
}

+ (UIColor *)remateGreen {
    return [UIColor colorWithRed:88.0/255.0 green:155.0/255.0 blue:9.0/255.0 alpha:1.0];
}

+ (UIColor *)remateBlue {
    return [UIColor colorWithRed:0.0/255.0 green:96.0/255.0 blue:134.0/255.0 alpha:1.0];
}

+ (UIColor *)remateTextColor {
    return [UIColor colorWithRed:0.0/255.0 green:96.0/255.0 blue:144.0/255.0 alpha:1.0];
}

+ (UIColor*)camecSuperLightGray{
    UIColor *color = [UIColor colorWithRed:222.0/255.0 green:134.0/255.0 blue:222.0/255.0 alpha:1] ;
    return color;
}

+ (UIColor*)camecLightGray{
    UIColor *color = [UIColor colorWithRed:182.0/255.0 green:182.0/255.0 blue:182.0/255.0 alpha:1] ;
    return color;
}

+ (UIColor *)camecIconDefaultNavigation {
    return [UIColor colorWithRed:74.0/255.0 green:74.0/255.0 blue:74.0/255.0 alpha:1.0];
}

+ (UIColor *)camecBlue {
    return [UIColor colorWithRed:74.0/255.0 green:144.0/255.0 blue:226.0/255.0 alpha:1.0];
}



@end
