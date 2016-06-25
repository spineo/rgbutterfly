//
//  GenericUtils.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 2/13/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import "GenericUtils.h"

@implementation GenericUtils

+ (NSMutableArray *)trimStrings:(NSArray *)stringList {
    NSMutableArray *trimmedStrings = [[NSMutableArray alloc] init];
    for (NSString *string in stringList) {
        NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [trimmedStrings addObject:trimmedString];
    }
    return trimmedStrings;
}

+ (NSString *)trimString:(NSString *)string {
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return trimmedString;
}

+ (NSString *)removeSpaces:(NSString *)string {
    NSString *noSpacesString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];

    return noSpacesString;
}

@end
