//
//  LivenessXResult.h
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 13/03/20.
//  Copyright © 2020 Matheus  domingos. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LivenessXResult : NSObject

@property(strong, nonatomic) NSString *base64;
@property(strong, nonatomic) NSString *processId;
@property(assign, nonatomic) BOOL isLiveness;


@end

NS_ASSUME_NONNULL_END
