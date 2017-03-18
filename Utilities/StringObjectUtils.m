//
//  StringObjectUtils.m
//  RGButterfly
//
//  Created by Stuart Pineo on 11/20/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "StringObjectUtils.h"
#import "GlobalSettings.h"

@implementation StringObjectUtils

+ (void)setFieldPlaceholder:(UITextField *)textField text:(NSString *)text {
    
    NSMutableAttributedString *placeHolderString = [[NSMutableAttributedString alloc] initWithString:text];
    textField.attributedPlaceholder = placeHolderString;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UIFont *placeholderFont = [defaults valueForKey:@"placeholderFont"];
    placeholderFont = placeholderFont ? placeholderFont : PLACEHOLDER_FONT;
    
    [[NSUserDefaults standardUserDefaults] setObject: placeholderFont forKey:@"placeholderFont"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [placeHolderString addAttribute:NSFontAttributeName value: PLACEHOLDER_FONT range:NSMakeRange(0, [text length])];
}

@end
