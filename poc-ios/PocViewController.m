//
//  PocViewController.m
//  poc-ios
//
//  Created by Matheus Domingos on 12/05/20.
//  Copyright © 2020 Acesso Digital. All rights reserved.
//

#import "PocViewController.h"


@interface PocViewController ()

@end


@implementation PocViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:@"POC"];
    
    url = @"https://crediariohomolog.acesso.io/Treinamento";
    apikey = @"";
    token = @"";
    
}

- (IBAction)openLivenessX:(id)sender {
    AcessoBioManager *acessoBioManager = [[AcessoBioManager alloc]initWithViewController:self url:url apikey:apikey token:token];
    [acessoBioManager openLivenessX];
}

- (IBAction)openLivenessXWithCreateProcess:(id)sender {
    AcessoBioManager *acessoBioManager = [[AcessoBioManager alloc]initWithViewController:self url:url apikey:apikey token:token];
    [acessoBioManager openLivenessXWithCreateProcess:@"12345678909" name:@"Matheus Domingos"];
}

- (IBAction)openCameraFace:(id)sender {
    AcessoBioManager *acessoBioManager = [[AcessoBioManager alloc]initWithViewController:self url:url apikey:apikey token:token];
    [acessoBioManager openCameraFace];
}

- (IBAction)openCameraFaceWithCreateProcess:(id)sender {
    AcessoBioManager *acessoBioManager = [[AcessoBioManager alloc]initWithViewController:self url:url apikey:apikey token:token];
    [acessoBioManager openCameraFaceWithCreateProcess:@"12345678909" name:@"Matheus Domingos"];
}

- (void)onSuccesLivenessX:(LivenessXResult *)result {
    NSLog(@"ao vivo? : %d", result.isLiveness);
    NSLog(@"base64 da foto: %@", result.base64);
    NSLog(@"id do processo: %@", result.processId);
}

- (void)onErrorLivenessX:(NSString *)error {
    NSLog(@"error: %@", error);
}

- (void)onSuccesCameraFace:(CameraFaceResult *)result {
    NSLog(@"base64 da foto: %@", result.base64);
    NSLog(@"id do processo: %@", result.processId);
}

- (void)onErrorCameraFace:(NSString *)error {
    NSLog(@"error: %@", error);
}

@end
