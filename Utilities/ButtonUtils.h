//
//  ButtonUtils.h
//  RGButterfly
//
//  Created by Stuart Pineo on 1/26/17.
//  Copyright © 2017 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ButtonUtils : NSObject

+ (BOOL)changeButtonRendering:(BOOL)isRGB refTag:(int)refTag toolBarItems:(NSArray *)toolBarItems;

+ (UIButton *)createButton:(NSString *)title tag:(int)tag;

+ (UIButton *)create3DButton:(NSString *)title tag:(int)tag frame:(CGRect)frame;

+ (UIButton *)create3DButton:(NSString *)title tag:(int)tag;

+ (UIButton *)set3DGradient:(UIButton *)button;

@end
