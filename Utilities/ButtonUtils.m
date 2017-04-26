//
//  ButtonUtils.m
//  RGButterfly
//
//  Created by Stuart Pineo on 1/26/17.
//  Copyright © 2017 Stuart Pineo. All rights reserved.
//

#import "ButtonUtils.h"
#import "BarButtonUtils.h"
#import "GlobalSettings.h"

@implementation ButtonUtils

+ (BOOL)changeButtonRendering:(BOOL)isRGB refTag:(int)refTag toolBarItems:(NSArray *)toolBarItems {
    
    NSString *imageName;
    if (isRGB == FALSE) {
        imageName = PALETTE_IMAGE_NAME;
        isRGB = TRUE;
        
    } else {
        imageName = RGB_IMAGE_NAME;
        isRGB = FALSE;
    }
    
    [BarButtonUtils setButtonImage:toolBarItems refTag:refTag imageName:imageName];
    
    return isRGB;
}

+ (UIButton *)createButton:(NSString *)title tag:(int)tag {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTag:tag];
    [button setFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, DEF_BUTTON_WIDTH, DEF_BUTTON_HEIGHT)];
    
    return button;
}

+ (UIButton *)create3DButton:(NSString *)title tag:(int)tag frame:(CGRect)frame {
    
    UIButton *button = [self create3DButton:title tag:tag];
    [button setFrame:frame];
    
    return button;
}

+ (UIButton *)create3DButton:(NSString *)title tag:(int)tag {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [button setTitle: title forState:UIControlStateNormal];
    [button setTintColor:DARK_TEXT_COLOR];
    [button setBackgroundColor:GRAY_BG_COLOR];
    [button setTag: tag];
    
    
    // Draw a custom gradient
    //
    CAGradientLayer *btnGradient = [CAGradientLayer layer];
    btnGradient.frame = button.bounds;
    btnGradient.colors = [NSArray arrayWithObjects:
                          (id)[[UIColor colorWithRed:180.0f / 255.0f green:180.0f / 255.0f blue:230.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:175.0f / 255.0f green:175.0f / 255.0f blue:225.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:170.0f / 255.0f green:170.0f / 255.0f blue:220.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:140.0f / 255.0f green:140.0f / 255.0f blue:180.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:100.0f / 255.0f green:100.0f / 255.0f blue:140.0f / 255.0f alpha:1.0f] CGColor],
                          nil];
    
    // Round button corners
    //
    CALayer *btnLayer = [button layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:DEF_CORNER_RADIUS];
    
    // Apply a 1 pixel, black border
    //
    [btnLayer setBorderWidth:DEF_BORDER_WIDTH];
    [btnLayer setBorderColor:[DARK_BORDER_COLOR CGColor]];
    
    [button.layer insertSublayer: btnGradient atIndex:0];
    
    return button;
}

// Create 3D Button with Dark Cradient
//
+ (UIButton *)set3DGradient:(UIButton *)button {
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [button.layer setMasksToBounds:YES];
    [button.layer setCornerRadius:15.0];
    [button.layer setBorderWidth:1.0];
    [button.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame            = button.bounds;
    gradient.colors           = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor grayColor] CGColor], nil];
    [button.layer insertSublayer:gradient atIndex:0];
        
    return button;
}


@end
