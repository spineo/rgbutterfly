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

+ (void)buttonSetTitle:(NSArray *)toolbarItems refTag:(int)refTag title:(NSString *)title;

+ (void)buttonSetWidth:(NSArray *)toolbarItems refTag:(int)refTag width:(CGFloat)width;

@end
