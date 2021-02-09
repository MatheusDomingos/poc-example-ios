//
//  ValidateLiveness.m
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 16/12/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import "ValidateLiveness.h"
#include <math.h>

float SCORE_MINIMUM = 74.0f;

@implementation ValidateLiveness


+ (NSDictionary *)validateLiveness : (NSDictionary *)pDictLiveness{
    
    float totalGrade = 0;
    
    // Veridfi
    BOOL isFastProcess = [[pDictLiveness valueForKey:@"isFastProcess"] boolValue];
    BOOL isBlinking = [[pDictLiveness valueForKey:@"isBlinking"] boolValue];
    BOOL isSmilling = [[pDictLiveness valueForKey:@"isSmilling"] boolValue];
    BOOL isFinishiWithoutTheSmile = [[pDictLiveness valueForKey:@"isFinishiWithoutTheSmile"] boolValue];
    
    
    BOOL photoCloseLive = [[pDictLiveness valueForKey:@"photoCloseLive"] boolValue];
    float photoCloseConfidence = [[pDictLiveness valueForKey:@"photoCloseConfidence"] floatValue];
    
    BOOL photoAwayLive = [[pDictLiveness valueForKey:@"photoAwayLive"] boolValue];
    float photoAwayConfidence = [[pDictLiveness valueForKey:@"photoAwayConfidence"] floatValue];
    
    
    // Calculos primários
    if(isSmilling) {
        totalGrade += 25.00;
    }
    
    if(isBlinking) {
        totalGrade += 25.00;
    }
    
    //Verifico se o processo foi rápido, impossibilitando assim a verificacao adequada do blink e atribuindo mais peso a IA.
    if((isFastProcess && !isBlinking) || isFinishiWithoutTheSmile) {
        
        if(photoCloseLive && (photoCloseConfidence >= 80)) {
            totalGrade += 37.5;
        }
        
        if(photoAwayLive && (photoAwayConfidence >= 80)) {
            totalGrade += 37.5;
        }
        
        // Calculos secundários
        
        /// Atribuo 25.0, pois em um cenário de captura rapida, 25 pontos do sorriso estao garantidos, sobrando um score de 50 para passar na analise.
        if(photoCloseLive && (photoCloseConfidence < 80)) {
            totalGrade += 25.0;
        }
        
        if(!photoCloseLive && (photoCloseConfidence < 70)) {
            totalGrade += 25.0;
        }
        
        if(photoAwayLive && (photoAwayConfidence < 80)) {
            totalGrade += 25.0;
        }
        
        if(!photoAwayLive && (photoAwayConfidence < 70)) {
            totalGrade += 25.0;
        }
        
    }else{
        
        if(photoCloseLive && (photoCloseConfidence >= 80)) {
            totalGrade += 25.0;
        }
        
        if(photoAwayLive && (photoAwayConfidence >= 80)) {
            totalGrade += 25.0;
        }
        
        
        if(photoCloseLive && (photoCloseConfidence < 80)) {
            totalGrade += 8.75;
        }
        
        if(!photoCloseLive && (photoCloseConfidence < 70)) {
            totalGrade += 8.75;
        }
        
        if(photoAwayLive && (photoAwayConfidence < 80)) {
            totalGrade += 8.75;
        }
        
        if(!photoAwayLive && (photoAwayConfidence < 70)) {
            totalGrade += 8.75;
        }
        
    }
    
    
    if(totalGrade >= SCORE_MINIMUM){
        return  @{@"isLive" : [NSNumber numberWithBool:YES], @"total" : [NSNumber numberWithFloat:totalGrade]};;
    }else{
        return  @{@"isLive" : [NSNumber numberWithBool:NO], @"total" : [NSNumber numberWithFloat:totalGrade]};;
    }
    
}

+ (NSDictionary *)validateLivenessV2:(NSDictionary *)pDictLiveness {
    
    int userBlinks = [[pDictLiveness valueForKey:@"userBlinks"] intValue];
    int timeLastSession = [[pDictLiveness valueForKey:@"timeLastSession"] intValue];
    int sessionWhichEnded = [[pDictLiveness valueForKey:@"sessionWhichEnded"] intValue];
    int timeToSmilling = [[pDictLiveness valueForKey:@"timeToSmilling"] intValue];
    int timeTotalProcess = [[pDictLiveness valueForKey:@"timeTotalProcess"] intValue];
    
    //BOOL photoCloseLive = [[pDictLiveness valueForKey:@"photoCloseLive"] boolValue];
    double photoCloseConfidence = [[pDictLiveness valueForKey:@"photoCloseConfidence"] doubleValue];
    
    //BOOL photoAwayLive = [[pDictLiveness valueForKey:@"photoAwayLive"] boolValue];
    double photoAwayConfidence = [[pDictLiveness valueForKey:@"photoAwayConfidence"] doubleValue];
    
    // Threshold
    double threshold = 70;
    
    // Variables
    double BP = 0; // blink proportion => time_total / blinks (se o blinks é 0, considerar BP = 0)
    if(userBlinks == 0){
        BP = 0;
    }else{
        BP =  (timeLastSession / userBlinks);
    }
    
    double SA = 0; // Score Away
    SA = photoAwayConfidence;
    double SC = 0; // Score Close
    SC = photoCloseConfidence;
    
    int TS = 0; // Time Smilling
    TS = (int) timeToSmilling;
    
    float   TT = 0; // Time total
    TT = timeTotalProcess;
    
    int TSe = 0; // Tempo da sessão em que acaba de concluir.
    TSe = (int) timeLastSession;
    
    int AT = 0; // Em qual session concluiu o processo (1,2 ou 3. Nunca será 0)
    AT = sessionWhichEnded;
    
    
    // Bases
    int BBP = 7; // Tempo comum em que um usuário costuma piscar
    int BTS = 3; // Tempo comum em que um usuário costuma sorrir
    int BTSe = 7; // Tempo Base em que um usuário costuma fechar uma sessão
    
    
    // Weights
    int PSC  = 1; // Peso para score close
    int PSA = 3; //  Peso para ScoreAway
    int PBP = 3; // Peso para BlinkPropor = 3 (se blinks for 0, então o peso cai para 2)
    if(userBlinks == 0) {
        PBP = 2;
    }
    int PTS = 2; // Peso para TimeSmiling
    int PTSe = 3; // Peso para TimeSession
    
    
    // Discounts
    double DB = 0.9;
    double DS  = 0.95;
    double DT = 0.95;
    
    
    /*
     // teste 1
     BP = 2.66666666;
     SC = 0.99454665;
     SA = 0.99698335;
     TS = 3;
     TT = 8;
     TSe = 8;
     
     
     // teste 2
     BP = 2.538461538;
     SC = 0.99987626;
     SA = 0.9999993;
     TS = 1;
     TT = 66;
     TSe = 66;
     
     // teste 3
     BP = 64;
     SC = 0.9998216;
     SA = 0.9999181;
     TS = 3;
     TT = 128;
     TSe = 128;*/
    
    // Formula
    double scoreV2  = ((SC*PSC) + (SA*PSA) + ((pow(DB , fabs(BBP - BP)))*PBP) + (( pow(DS, abs(BTS - TS)))* PTS) + (( pow(DT, abs(BTSe - TSe)))* PTSe))/(PSC+PSA+PBP+PTS+PTSe);
    scoreV2 = scoreV2 * 100;
    
    BOOL isLive = NO;
    
    if(scoreV2 >= SCORE_MINIMUM) {
        isLive = YES;
    }
            
    NSDictionary *result = @{@"isLive" : [NSNumber numberWithBool:isLive], @"total": [NSNumber numberWithDouble:scoreV2]};
    return result;

}

@end
