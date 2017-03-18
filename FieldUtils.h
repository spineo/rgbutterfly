//
//  FieldUtils.h
//  RGButterfly
//
//  Created by Stuart Pineo on 7/3/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FieldUtils : NSObject

+ (UILabel *)createLabel:(NSString *)name;

+ (UILabel *)createLabel:(NSString *)name xOffset:(CGFloat)x yOffset:(CGFloat)y;

+ (UILabel *)createLabel:(NSString *)name xOffset:(CGFloat)x yOffset:(CGFloat)y width:(CGFloat)width height:(CGFloat)height;

+ (UILabel *)createSmallLabel:(NSString *)name xOffset:(CGFloat)x yOffset:(CGFloat)y;

+ (UILabel *)createLargeLabel:(NSString *)name xOffset:(CGFloat)x yOffset:(CGFloat)y;

+ (UITextField *)createTextField:(NSString *)name tag:(NSInteger)tag;

+ (UITextView *)createTextView:(NSString *)name tag:(NSInteger)tag;

+ (UIPickerView *)createPickerView:(CGFloat)width tag:(NSInteger)tag;

+ (UIPickerView *)createPickerView:(CGFloat)width tag:(NSInteger)tag xOffset:(CGFloat)x yOffset:(CGFloat)y;

+ (void)makeTextFieldNonEditable:(UITextField *)refName content:(NSString *)content border:(BOOL)border;

+ (void)makeTextFieldEditable:(UITextField *)refName content:(NSString *)content;

+ (void)makeTextViewNonEditable:(UITextView *)refName content:(NSString *)content border:(BOOL)border;

+ (void)makeTextViewEditable:(UITextView *)refName content:(NSString *)content;

@end
