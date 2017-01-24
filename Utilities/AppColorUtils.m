//
//  ColorUtils.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 5/6/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "AppColorUtils.h"
#import "GlobalSettings.h"

@implementation AppColorUtils


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// COLOR return methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

+ (NSString *)colorCategoryFromHue:(PaintSwatches *)swatchObj {
    int degHue = [[swatchObj deg_hue] intValue];

    int red    = [[swatchObj red] intValue];
    int green  = [[swatchObj green] intValue];
    int blue   = [[swatchObj blue] intValue];
    
    return [ColorUtils colorCategoryFromHue:degHue red:red green:green blue:blue];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// IMAGE return methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

+ (UIImage *)imageWithColor:(UIColor *)color objWidth:(CGFloat)width objHeight:(CGFloat)height {
    CGRect rect = CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, width, height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    //CGContextStrokeEllipseInRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)resizeImage:(UIImage *)image imageSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Here is the scaled image which has been changed to the size specified
    //
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)renderSwatch:(PaintSwatches *)swatchObj  cellWidth:(CGFloat)width cellHeight:(CGFloat)height {
    BOOL isRGB = [[NSUserDefaults standardUserDefaults] boolForKey:RGB_DISPLAY_KEY];
    
    UIImage *swatchImage;
    if (isRGB == FALSE) {
        swatchImage = [self renderPaint:swatchObj.image_thumb cellWidth:width cellHeight:height];
    } else {
        swatchImage = [self renderRGB:swatchObj cellWidth:width cellHeight:height];
    }
    return swatchImage;
}

+ (UIImage *)renderRGB:(PaintSwatches *)swatchObj cellWidth:(CGFloat)width cellHeight:(CGFloat)height {
    return [self imageWithColor:[self colorFromSwatch:swatchObj] objWidth:width objHeight:height];
}

+ (UIColor *)colorFromSwatch:(PaintSwatches *)swatchObj {
    return [UIColor colorWithRed:([swatchObj.red floatValue]/255.0) green:([swatchObj.green floatValue]/255.0) blue:([swatchObj.blue floatValue]/255.0) alpha:[swatchObj.alpha floatValue]];
}

+ (UIImage *)renderPaint:(id)image_thumb cellWidth:(CGFloat)width cellHeight:(CGFloat)height {
    CGSize size = CGSizeMake(width, height);
    
    UIImage *resizedImage   = [self resizeImage:[UIImage imageWithData:image_thumb] imageSize:size];
    
    return resizedImage;
}

+ (UIImage*)drawRGBLabel:(UIImage*)image rgbValue:(PaintSwatches *)paintSwatch location:(NSString *)location {
    UIImage *retImage = image;
    
    NSString *rgbValue = [[NSString alloc] initWithFormat:@"RGB=%i,%i,%i Hue=%i", [[paintSwatch red] intValue], [[paintSwatch green] intValue], [[paintSwatch blue] intValue], [[paintSwatch deg_hue] intValue]];
    
    UIGraphicsBeginImageContext(image.size);
    
    [retImage drawInRect:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, image.size.width, image.size.height)];
    
    CGRect rect = CGRectMake(DEF_X_COORD, DEF_Y_COORD, image.size.width, image.size.height);
    if ([location isEqualToString:@"bottom"]) {
        CGFloat fontHeight = [LG_TAP_AREA_FONT pointSize];
        CGFloat yLocation = image.size.height - (fontHeight + DEF_RECT_INSET + DEF_BOTTOM_OFFSET);
        rect = CGRectMake(DEF_X_COORD, yLocation, image.size.width, image.size.height);
    }
    
    NSDictionary *attr = @{NSForegroundColorAttributeName:LIGHT_TEXT_COLOR, NSFontAttributeName:LG_TAP_AREA_FONT, NSBackgroundColorAttributeName:DARK_BG_COLOR};
    
    [rgbValue drawInRect:CGRectInset(rect, DEF_RECT_INSET, DEF_RECT_INSET) withAttributes:attr];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)cropImage:(UIImage*)image frame:(CGRect)rect {
    rect = CGRectMake(rect.origin.x    * image.scale,
                      rect.origin.y    * image.scale,
                      rect.size.width  * image.scale,
                      rect.size.height * image.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef
                                                scale:image.scale
                                          orientation:image.imageOrientation];
    
    CGImageRelease(imageRef);
    
    return croppedImage;
}

+ (UIColor *)setBestColorContrast:(NSString *)colorName {
    UIColor *textColor = DARK_TEXT_COLOR;
    if ([colorName isEqualToString:@"Black"] || [colorName isEqualToString:@"Blue"] ||
        [colorName isEqualToString:@"Brown"] || [colorName isEqualToString:@"Blue Violet"]) {
        textColor = LIGHT_TEXT_COLOR;
    }
    
    return textColor;
}

@end
