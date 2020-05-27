//
//  AppDelegate.m
//  poc-ios
//
//  Created by Matheus Domingos on 11/05/20.
//  Copyright © 2020 Acesso Digital. All rights reserved.
//

#import "AppDelegate.h"
#import "PocViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [FIRApp configure];

      PocViewController *pView = [PocViewController new];
      UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:pView];
    //  [nav.navigationBar setTranslucent:YES];
      self.window.rootViewController = nav;
      [self.window makeKeyAndVisible];
      
    
    return YES;
}


@end
