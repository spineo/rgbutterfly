//
//  ColorUtils.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 5/6/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PaintSwatches.h"
#import "ColorUtils.h"

@interface AppColorUtils : NSObject

+ (NSString *)colorCategoryFromHue:(PaintSwatches *)swatchObj;
+ (UIImage *)imageWithColor:(UIColor *)color objWidth:(CGFloat)width objHeight:(CGFloat)height;
+ (UIImage*)resizeImage:(UIImage *)image imageSize:(CGSize)size;
+ (UIImage *)renderSwatch:(PaintSwatches *)swatchObj  cellWidth:(CGFloat)width cellHeight:(CGFloat)height;
+ (UIImage *)renderRGB:(PaintSwatches *)swatchObj cellWidth:(CGFloat)width cellHeight:(CGFloat)height;
+ (UIColor *)colorFromSwatch:(PaintSwatches *)swatchObj;
+ (UIImage *)renderPaint:(id)image_thumb cellWidth:(CGFloat)width cellHeight:(CGFloat)height;
+ (UIImage*)drawRGBLabel:(UIImage*)image rgbValue:(PaintSwatches *)paintSwatch location:(NSString *)location;
+ (UIImage *)cropImage:(UIImage*)image frame:(CGRect)rect;
+ (UIColor *)setBestColorContrast:(NSString *)colorName;

@end
