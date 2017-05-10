//
//  ColorUtils.h
//  RGButterfly
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
+ (UIImage *)renderSwatch:(PaintSwatches *)swatchObj  cellWidth:(CGFloat)width cellHeight:(CGFloat)height context:(NSManagedObjectContext *)context;
+ (UIImage *)renderRGB:(PaintSwatches *)swatchObj cellWidth:(CGFloat)width cellHeight:(CGFloat)height;
+ (UIImage *)renderRGBFromValues:(NSString *)red green:(NSString *)green blue:(NSString *)blue alpha:(NSString *)alpha cellWidth:(CGFloat)width cellHeight:(CGFloat)height;
+ (UIColor *)colorFromSwatch:(PaintSwatches *)swatchObj;
+ (UIImage *)renderPaint:(id)image_thumb cellWidth:(CGFloat)width cellHeight:(CGFloat)height;
+ (UIImage*)drawRGBLabel:(UIImage*)image rgbValue:(PaintSwatches *)paintSwatch location:(NSString *)location;

@end
