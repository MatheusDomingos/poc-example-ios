//
//  ValidateLiveness.h
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 16/12/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ValidateLiveness : NSObject

+ (NSDictionary *)validateLiveness : (NSDictionary *)pDictLiveness;
+ (NSDictionary *)validateLivenessV2:(NSDictionary *)pDictLiveness;
@end

NS_ASSUME_NONNULL_END
