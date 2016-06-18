//
//  BarButtonUtils.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 5/19/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BarButtonUtils : NSObject

+ (NSArray *)setButtonImage:(NSArray *)toolbarItems refTag:(int)tag imageName:(NSString *)name;

+ (NSArray *)setButtonName:(NSArray *)toolbarItems refTag:(int)tag buttonName:(NSString *)label;

+ (void)buttonEnabled:(NSArray *)toolbarItems refTag:(int)refTag isEnabled:(BOOL)isEnabled;

+ (void)buttonShow:(NSArray *)toolbarItems refTag:(int)refTag;

+ (void)buttonHide:(NSArray *)toolbarItems refTag:(int)refTag;

+ (void)buttonSetWidth:(NSArray *)toolbarItems refTag:(int)refTag width:(CGFloat)width;

+ (BOOL)changeButtonRendering:(BOOL)isRGB refTag:(int)refTag toolBarItems:(NSArray *)toolBarItems;

+ (UIButton *)createButton:(NSString *)title tag:(int)tag;

+ (UIButton *)create3DButton:(NSString *)title tag:(int)tag frame:(CGRect)frame;

+ (UIButton *)create3DButton:(NSString *)title tag:(int)tag;

@end
