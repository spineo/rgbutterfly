//
//  ACPString.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 10/24/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "ACPString.h"

@implementation ACPString

- (BOOL)containsString: (NSString*)substring {
    NSRange range = [self rangeOfString : substring];
    BOOL found = ( range.location != NSNotFound );
    return found;
}

@end
