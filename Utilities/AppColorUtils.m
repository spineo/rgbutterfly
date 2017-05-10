//
//  ColorUtils.m
//  RGButterfly
//
//  Created by Stuart Pineo on 5/6/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "AppColorUtils.h"
#import "GlobalSettings.h"
#import "ManagedObjectUtils.h"

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

+ (UIImage *)renderSwatch:(PaintSwatches *)swatchObj  cellWidth:(CGFloat)width cellHeight:(CGFloat)height context:(NSManagedObjectContext *)context {
    BOOL isRGB = [[NSUserDefaults standardUserDefaults] boolForKey:RGB_DISPLAY_KEY];
    
    int type_id = [[swatchObj type_id] intValue];
    
    NSString *typeName = [[ManagedObjectUtils queryDictionaryName:@"PaintSwatchType" entityId:type_id context:context] name];
    
    UIImage *swatchImage;
    
    // 'GenericPaint' types are always rendered using RGB values
    //
    if (isRGB == FALSE && ![typeName isEqualToString:@"GenericPaint"]) {
        swatchImage = [self renderPaint:swatchObj.image_thumb cellWidth:width cellHeight:height];
    } else {
        swatchImage = [self renderRGB:swatchObj cellWidth:width cellHeight:height];
    }
    return swatchImage;
}

+ (UIImage *)renderRGB:(PaintSwatches *)swatchObj cellWidth:(CGFloat)width cellHeight:(CGFloat)height {
    return [ColorUtils imageWithColor:[self colorFromSwatch:swatchObj] objWidth:width objHeight:height];
}

+ (UIImage *)renderRGBFromValues:(NSString *)red green:(NSString *)green blue:(NSString *)blue alpha:(NSString *)alpha cellWidth:(CGFloat)width cellHeight:(CGFloat)height {

    UIColor *rgbColor = [UIColor colorWithRed:([red floatValue]/255.0) green:([green floatValue]/255.0) blue:([blue floatValue]/255.0) alpha:[alpha floatValue]];

    return [ColorUtils imageWithColor:rgbColor objWidth:width objHeight:height];
}

+ (UIColor *)colorFromSwatch:(PaintSwatches *)swatchObj {
    return [UIColor colorWithRed:([swatchObj.red floatValue]/255.0) green:([swatchObj.green floatValue]/255.0) blue:([swatchObj.blue floatValue]/255.0) alpha:[swatchObj.alpha floatValue]];
}

+ (UIImage *)renderPaint:(id)image_thumb cellWidth:(CGFloat)width cellHeight:(CGFloat)height {
    CGSize size = CGSizeMake(width, height);
    
    UIImage *resizedImage = [ColorUtils resizeImage:[UIImage imageWithData:image_thumb] imageSize:size];
    
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


@end
