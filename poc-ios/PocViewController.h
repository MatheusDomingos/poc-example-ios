//
//  PocViewController.h
//  poc-ios
//
//  Created by Matheus Domingos on 12/05/20.
//  Copyright © 2020 Acesso Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AcessoBioManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface PocViewController : UIViewController <AcessoBioDelegate> {
    
    NSString *url;
    NSString *apikey;
    NSString *token;
    
}

@end

NS_ASSUME_NONNULL_END
