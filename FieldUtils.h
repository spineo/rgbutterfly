//
//  FieldUtils.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 7/3/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FieldUtils : NSObject

+ (UILabel *)createLabel:(NSString *)name xOffset:(CGFloat)x yOffset:(CGFloat)y;

+ (UILabel *)createSmallLabel:(NSString *)name xOffset:(CGFloat)x yOffset:(CGFloat)y;

+ (UILabel *)createLargeLabel:(NSString *)name xOffset:(CGFloat)x yOffset:(CGFloat)y;

+ (UITextField *)createTextField:(NSString *)name tag:(NSInteger)tag;

+ (UITextView *)createTextView:(NSString *)name tag:(NSInteger)tag;

+ (UIPickerView *)createPickerView:(CGFloat)width tag:(NSInteger)tag;

@end
