//
//  GenericUtils.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 2/13/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface GenericUtils : NSObject

// Trim list or individual string of leading/trailing whitespace
//
+ (NSMutableArray *)trimStrings:(NSArray *)stringList;
+ (NSString *)trimString:(NSString *)string;
+ (NSString *)removeSpaces:(NSString *)string;
+ (NSString *)getCurrDateString;
+ (NSString *)getCurrDateIdentifier;
+ (int)checkForDBUpdate;
+ (NSString *)updateDB;

@end
