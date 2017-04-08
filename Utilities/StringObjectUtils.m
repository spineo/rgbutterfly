//
//  StringObjectUtils.m
//  RGButterfly
//
//  Created by Stuart Pineo on 11/20/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//
#import "StringObjectUtils.h"
#import "GlobalSettings.h"

#include <regex.h>

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

+ (NSRange)matchString:(NSString *)string toRegex:(NSString *)regex {
    regex_t regex_obj;
    regmatch_t match;
    const char *regex_str;
    const char *match_str;
    int error;
    
    regex_str = [regex UTF8String];
    error = regcomp(&regex_obj, regex_str, REG_EXTENDED);
    if (error)
    {
        return NSMakeRange(NSNotFound, 0);
    }
    
    match_str = [string UTF8String];
    error = regexec(&regex_obj, match_str, 1, &match, 0);
    if (error)
    {
        return NSMakeRange(NSNotFound, 0);
    }
    
    regfree(&regex_obj);
    return NSMakeRange(match.rm_so, match.rm_eo - match.rm_so);
}

@end
