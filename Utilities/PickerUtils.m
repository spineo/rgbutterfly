//
//  PickerUtils.m
//  RGButterfly
//
//  Created by Stuart Pineo on 6/20/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import "PickerUtils.h"
#import "GlobalSettings.h"
#import "FieldUtils.h"

@implementation PickerUtils

+ (UIPickerView *)createPickerView:(NSInteger)tag  xOffset:(CGFloat)x yOffset:(CGFloat)y {
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, DEF_PICKER_WIDTH, DEF_PICKER_HEIGHT)];
    [pickerView setBackgroundColor: DARK_BG_COLOR];
    [pickerView setShowsSelectionIndicator:YES];
    [pickerView setTag:tag];
    
    return pickerView;
}

// Generic Picker method
//
+ (UIPickerView *)createPicker:(id)sender tag:(int)pickerTag selectRow:(int)selectRow action:(SEL)action textField:(UITextField *)textField {
    UIPickerView *picker = [self createPickerView:pickerTag xOffset:DEF_X_OFFSET yOffset:DEF_TOOLBAR_HEIGHT];
    [picker setDelegate:sender];
    [picker setDataSource:sender];
    [picker selectRow:selectRow inComponent:0 animated:YES];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:sender action:action];
    tapRecognizer.numberOfTapsRequired = DEF_NUM_TAPS;
    [picker addGestureRecognizer:tapRecognizer];
    [tapRecognizer setDelegate:sender];
    
    [textField setInputView:picker];
    
    return picker;
}

+ (UIView *)addPickerDone:(id)sender picker:(UIPickerView *)picker action:(SEL)action textField:(UITextField *)textField {
    UIToolbar* pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, DEF_PICKER_WIDTH, DEF_TOOLBAR_HEIGHT)];
    [pickerToolbar setBarStyle:UIBarStyleBlackTranslucent];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:sender action:action];
    [doneButton setTintColor:LIGHT_TEXT_COLOR];
    
    [pickerToolbar setItems: @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton]];
    
    UIView *pickerParentView = [[UIView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, DEF_PICKER_WIDTH, DEF_PICKER_HEIGHT + DEF_TOOLBAR_HEIGHT)];
    [pickerParentView setBackgroundColor:DARK_BG_COLOR];
    [pickerParentView addSubview:pickerToolbar];
    [pickerParentView addSubview:picker];
    
    [pickerToolbar sizeToFit];
    
    return pickerParentView;
}

@end
