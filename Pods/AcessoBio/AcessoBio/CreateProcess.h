//
//  CreateProcess.h
//  CaptureAcesso
//
//  Created by Matheus Domingos on 10/05/20.
//  Copyright © 2020 Matheus  domingos. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CreateProcess : NSObject

@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *birthdate;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phone;

@end

NS_ASSUME_NONNULL_END
