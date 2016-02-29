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

+ (UIAlertView *)createOkAlert:(NSString *)title message:(NSString *)message;

+ (void)noValueAlert;

+ (void)sizeLimitAlert:(int)size;

+ (void)rowLimitAlert:(int)size;

+ (void)valueExistsAlert;

@end
