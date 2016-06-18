//
//  BarButtonUtils.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 5/19/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "BarButtonUtils.h"
#import "GlobalSettings.h"


@implementation BarButtonUtils

+ (NSArray *)setButtonImage:(NSArray *)toolbarItems refTag:(int)tag imageName:(NSString *)name {

    int buttonCount = (int)toolbarItems.count;
    
    UIImage *colorRenderingImage;
    
    for (int i=0; i<buttonCount; i++) {
        UIBarButtonItem *refButton = [toolbarItems objectAtIndex:i];
        int refTag = (int)refButton.tag;
        
        if (refTag == tag) {
            colorRenderingImage = [UIImage imageNamed:name];

            [[toolbarItems objectAtIndex:i] setImage:colorRenderingImage];
            
            break;
        }
    }
    return toolbarItems;
}

+ (NSArray *)setButtonName:(NSArray *)toolbarItems refTag:(int)tag buttonName:(NSString *)label {
    
    int buttonCount = (int)toolbarItems.count;
    
    for (int i=0; i<buttonCount; i++) {
        UIBarButtonItem *refButton = [toolbarItems objectAtIndex:i];
        int refTag = (int)refButton.tag;
        
        if (refTag == tag) {
            [[toolbarItems objectAtIndex:i] setTitle:label];
            
            break;
        }
    }
    return toolbarItems;
}

+ (void)buttonEnabled:(NSArray *)toolbarItems refTag:(int)refTag isEnabled:(BOOL)isEnabled {

    int buttonCount = (int)toolbarItems.count;

    for (int i=0; i<buttonCount; i++) {
        UIBarButtonItem *refButton = [toolbarItems objectAtIndex:i];
        int buttonTag = (int)refButton.tag;
        
        if (refTag == buttonTag) {
            [ [toolbarItems objectAtIndex:i ] setEnabled:(isEnabled) ];
        }
    }
}

+ (void)buttonShow:(NSArray *)toolbarItems refTag:(int)refTag {
    
    int buttonCount = (int)toolbarItems.count;
    
    for (int i=0; i<buttonCount; i++) {
        UIBarButtonItem *refButton = [toolbarItems objectAtIndex:i];
        int buttonTag = (int)refButton.tag;
        
        if (refTag == buttonTag) {
            [[toolbarItems objectAtIndex:i ] setEnabled:TRUE ];
            [[toolbarItems objectAtIndex:i ] setTintColor:nil];
        }
    }
}

+ (void)buttonHide:(NSArray *)toolbarItems refTag:(int)refTag {
    
    int buttonCount = (int)toolbarItems.count;
    
    for (int i=0; i<buttonCount; i++) {
        UIBarButtonItem *refButton = [toolbarItems objectAtIndex:i];
        int buttonTag = (int)refButton.tag;
        
        if (refTag == buttonTag) {
            [[toolbarItems objectAtIndex:i ] setEnabled:FALSE ];
            [[toolbarItems objectAtIndex:i ] setTintColor: CLEAR_COLOR];
        }
    }
}

+ (void)buttonSetWidth:(NSArray *)toolbarItems refTag:(int)refTag width:(CGFloat)width {
    
    int buttonCount = (int)toolbarItems.count;
    
    for (int i=0; i<buttonCount; i++) {
        UIBarButtonItem *refButton = [toolbarItems objectAtIndex:i];
        int buttonTag = (int)refButton.tag;
        
        if (refTag == buttonTag) {
            [[toolbarItems objectAtIndex:i ] setWidth:width ];
        }
    }
}

+ (BOOL)changeButtonRendering:(BOOL)isRGB refTag:(int)refTag toolBarItems:(NSArray *)toolBarItems {
    
    NSString *imageName;
    if (isRGB == FALSE) {
        imageName = PALETTE_IMAGE_NAME;
        isRGB = TRUE;
        
    } else {
        imageName = RGB_IMAGE_NAME;
        isRGB = FALSE;
    }
    
    toolBarItems = [BarButtonUtils setButtonImage:toolBarItems refTag:refTag imageName:imageName];
    
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


@end
