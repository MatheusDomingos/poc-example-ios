//
//  OCRResult.h
//  AcessoBio
//
//  Created by Matheus Domingos on 10/08/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCRResult : NSObject

@property (strong, nonatomic) NSString *BirthDate;
@property (strong, nonatomic) NSString *Category;
@property (strong, nonatomic) NSString *Code;
@property (strong, nonatomic) NSString *ExpeditionCity;
@property (strong, nonatomic) NSString *ExpeditionDate;
@property (strong, nonatomic) NSString *ExpirationDate;
@property (strong, nonatomic) NSString *FatherName;
@property (strong, nonatomic) NSString *FirstLicenseDate;
@property (strong, nonatomic) NSString *MirrorNumber;
@property (strong, nonatomic) NSString *MotherName;
@property (strong, nonatomic) NSString *Name;
@property (strong, nonatomic) NSString *RG;
@property (strong, nonatomic) NSString *RegistrationNumber;
@property (strong, nonatomic) NSString *Renach;
@property (strong, nonatomic) NSString *SecurityCode;

@end

NS_ASSUME_NONNULL_END
