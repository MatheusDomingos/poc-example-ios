//
//  FacematchResult.h
//  AcessoBio
//
//  Created by Matheus Domingos on 10/08/20.
//  Copyright © 2020 Matheus Domingos Acesso. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FacematchResult : NSObject

@property (strong, nonatomic) NSString *Base64Document;
@property (strong, nonatomic) NSString *Base64Selfie;

@property (assign, nonatomic) NSInteger Status;

@end

NS_ASSUME_NONNULL_END
