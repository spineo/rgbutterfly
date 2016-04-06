//
//  AlertUtils.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 11/15/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AlertUtils : NSObject

+ (UIAlertController *)createOkAlert:(NSString *)title message:(NSString *)message;

+ (UIAlertController *)noValueAlert;

+ (UIAlertController *)noSaveAlert;

+ (UIAlertController *)sizeLimitAlert:(int)size;

+ (UIAlertController *)rowLimitAlert:(int)size;

+ (UIAlertController *)valueExistsAlert;

@end
