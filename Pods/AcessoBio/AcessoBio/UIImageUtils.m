//
//  UIImageUtils.m
//  FaceCapture
//
//  Created by Arkivus on 09/03/17.
//  Copyright © 2017 Arkivus. All rights reserved.
//

#import "UIImageUtils.h"
#import <CommonCrypto/CommonCrypto.h>

// This makes debugging much more fun
typedef union {
    uint32_t raw;
    unsigned char bytes[4];
    struct {
        char red;
        char green;
        char blue;
        char alpha;
    } __attribute__ ((packed)) pixels;
} FBComparePixel;

@implementation UIImageUtils

+ (UIImage *)flipImage:(UIImage *)image {
    UIGraphicsBeginImageContext(image.size);
    CGContextDrawImage(UIGraphicsGetCurrentContext(),CGRectMake(0.,0., image.size.width, image.size.height), image.CGImage);
    UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return i;
}

+ (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees {
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, oldImage.size.height, oldImage.size.width)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);
    
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.height / 2, -oldImage.size.width / 2, oldImage.size.height, oldImage.size.width), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSString *)getBase64Image:(UIImage*)image {
    NSString *base64Image = nil;
    
    @try {
        NSData *imageData;
        if (image.size.width == 480) {
            imageData = UIImageJPEGRepresentation(image, 1.0);
        } else {
            imageData = UIImageJPEGRepresentation(image, 0.8);
        }
        
        base64Image = [imageData base64EncodedStringWithOptions:0];
    }
    @catch (NSException *exception) {
        NSLog(@"error while get base64Image: %@", [exception reason]);
    }
    
    return base64Image;
}


+ (BOOL)fb_compareWithImage:(UIImage *)image imageToCompare: (UIImage *)imageToCompare tolerance:(CGFloat)tolerance
{
    // NSAssert(CGSizeEqualToSize(self.size, image.size), @"Images must be same size.");
    
    CGSize referenceImageSize = CGSizeMake(CGImageGetWidth(imageToCompare.CGImage), CGImageGetHeight(imageToCompare.CGImage));
    CGSize imageSize = CGSizeMake(CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage));
    
    // The images have the equal size, so we could use the smallest amount of bytes because of byte padding
    size_t minBytesPerRow = MIN(CGImageGetBytesPerRow(imageToCompare.CGImage), CGImageGetBytesPerRow(image.CGImage));
    size_t referenceImageSizeBytes = referenceImageSize.height * minBytesPerRow;
    void *referenceImagePixels = calloc(1, referenceImageSizeBytes);
    void *imagePixels = calloc(1, referenceImageSizeBytes);
    
    if (!referenceImagePixels || !imagePixels) {
        free(referenceImagePixels);
        free(imagePixels);
        return NO;
    }
    
    CGContextRef referenceImageContext = CGBitmapContextCreate(referenceImagePixels,
                                                               referenceImageSize.width,
                                                               referenceImageSize.height,
                                                               CGImageGetBitsPerComponent(imageToCompare.CGImage),
                                                               minBytesPerRow,
                                                               CGImageGetColorSpace(imageToCompare.CGImage),
                                                               (CGBitmapInfo)kCGImageAlphaPremultipliedLast
                                                               );
    CGContextRef imageContext = CGBitmapContextCreate(imagePixels,
                                                      imageSize.width,
                                                      imageSize.height,
                                                      CGImageGetBitsPerComponent(image.CGImage),
                                                      minBytesPerRow,
                                                      CGImageGetColorSpace(image.CGImage),
                                                      (CGBitmapInfo)kCGImageAlphaPremultipliedLast
                                                      );
    
    if (!referenceImageContext || !imageContext) {
        CGContextRelease(referenceImageContext);
        CGContextRelease(imageContext);
        free(referenceImagePixels);
        free(imagePixels);
        return NO;
    }
    
    CGContextDrawImage(referenceImageContext, CGRectMake(0, 0, referenceImageSize.width, referenceImageSize.height), imageToCompare.CGImage);
    CGContextDrawImage(imageContext, CGRectMake(0, 0, imageSize.width, imageSize.height), image.CGImage);
    
    CGContextRelease(referenceImageContext);
    CGContextRelease(imageContext);
    
    BOOL imageEqual = YES;
    
    // Do a fast compare if we can
    if (tolerance == 0) {
        imageEqual = (memcmp(referenceImagePixels, imagePixels, referenceImageSizeBytes) == 0);
    } else {
        // Go through each pixel in turn and see if it is different
        const NSInteger pixelCount = referenceImageSize.width * referenceImageSize.height;
        
        FBComparePixel *p1 = referenceImagePixels;
        FBComparePixel *p2 = imagePixels;
        
        NSInteger numDiffPixels = 0;
        for (int n = 0; n < pixelCount; ++n) {
            // If this pixel is different, increment the pixel diff count and see
            // if we have hit our limit.
            if (p1->raw != p2->raw) {
                numDiffPixels ++;
                
                CGFloat percent = (CGFloat)numDiffPixels / pixelCount;
                if (percent > tolerance) {
                    imageEqual = NO;
                    break;
                }
            }
            
            p1++;
            p2++;
        }
    }
    
    free(referenceImagePixels);
    free(imagePixels);
    
    return imageEqual;
    
    
}

+ (UIImage *)imageToGreyImage:(UIImage *)image {
    // Create image rectangle with current image width/height
    CGFloat actualWidth = image.size.width;
    CGFloat actualHeight = image.size.height;
    
    CGRect imageRect = CGRectMake(0, 0, actualWidth, actualHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context = CGBitmapContextCreate(nil, actualWidth, actualHeight, 8, 0, colorSpace, kCGImageAlphaNone);
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    CGImageRef grayImage = CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    context = CGBitmapContextCreate(nil, actualWidth, actualHeight, 8, 0, nil, kCGImageAlphaOnly);
    CGContextDrawImage(context, imageRect, [image CGImage]);
    CGImageRef mask = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage *grayScaleImage = [UIImage imageWithCGImage:CGImageCreateWithMask(grayImage, mask) scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(grayImage);
    CGImageRelease(mask);
    
    // Return the new grayscale image
    return grayScaleImage;
}

+ (void)generateHashFromImage: (UIImage *)image {
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    CC_MD5([imageData bytes], [imageData length], result);
    NSString *imageHash = [NSString stringWithFormat:
                           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    
    
    NSLog(@"%@", imageHash);
    
}

+ (UIImage *)crop:(CGRect)rect image :(UIImage *)image {
    
    float scale = [[UIScreen mainScreen] scale];
    
    if (scale > 1.0f) {
        rect = CGRectMake(rect.origin.x * scale,
                          rect.origin.y * scale,
                          rect.size.width * scale,
                          rect.size.height * scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:(scale * 25) orientation:[image imageOrientation]];
    CGImageRelease(imageRef);
    return result;
    
}

@end
