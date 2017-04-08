//
//  StringObjectUtils.h
//  RGButterfly
//
//  Created by Stuart Pineo on 11/20/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface StringObjectUtils : NSObject

+ (void)setFieldPlaceholder:(UITextField *)textField text:(NSString *)text;
+ (NSRange)matchString:(NSString *)string toRegex:(NSString *)regex;

@end
