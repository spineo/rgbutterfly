//
//  FieldUtils.m
//  RGButterfly
//
//  Created by Stuart Pineo on 7/3/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "FieldUtils.h"
#import "GlobalSettings.h"

@implementation FieldUtils

+ (UILabel *)createLabel:(NSString *)name {
    UILabel *label = [[UILabel alloc] init];
    
    [label setText:name];
    [label setBackgroundColor:DARK_TEXT_COLOR];
    [label setTextColor:LIGHT_TEXT_COLOR];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setFont:ITALIC_FONT];
    
    return label;
}

+ (UILabel *)createLabel:(NSString *)name xOffset:(CGFloat)x yOffset:(CGFloat)y {
    UILabel *label = [self createLabel:name];
    [label sizeToFit];
    CGFloat width = label.bounds.size.width;
    [label setFrame:CGRectMake(x, y, width, DEF_LABEL_HEIGHT)];
    
    return label;
}

+ (UILabel *)createLabel:(NSString *)name xOffset:(CGFloat)x yOffset:(CGFloat)y width:(CGFloat)width height:(CGFloat)height {
    UILabel *label = [self createLabel:name];
    [label setFrame:CGRectMake(x, y, width, height)];
    
    return label;
}

+ (UILabel *)createSmallLabel:(NSString *)name xOffset:(CGFloat)x yOffset:(CGFloat)y {
    
    UILabel *label = [self createLabel:name xOffset:x yOffset:y];
    [label setFont: SMALL_FONT];
    
    return label;
}

+ (UILabel *)createLargeLabel:(NSString *)name xOffset:(CGFloat)x yOffset:(CGFloat)y {
    UILabel *label = [self createLabel:name xOffset:x yOffset:y];
    [label setFont: LARGE_BOLD_FONT];
    
    return label;
}

+ (UITextField *)createTextField:(NSString *)name tag:(NSInteger)tag {
    UITextField *textField = [[UITextField alloc] init];
    [textField setBackgroundColor: LIGHT_BG_COLOR];
    [textField setTextColor: DARK_TEXT_COLOR];
    [textField.layer setCornerRadius: DEF_CORNER_RADIUS];
    [textField.layer setBorderWidth: DEF_BORDER_WIDTH];
    [textField setTag:tag];
    [textField setTextAlignment:NSTextAlignmentLeft];
    [textField setClearButtonMode: UITextFieldViewModeWhileEditing];
    [textField setFont:TEXT_FIELD_FONT];
    [textField setText:name];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, DEF_FIELD_PADDING, DEF_TEXTFIELD_HEIGHT)];
    [textField      setLeftView: paddingView];
    [textField      setLeftViewMode: UITextFieldViewModeAlways];
    
    // Allow for rotation
    //
    [textField setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    
    return textField;
}

+ (UITextView *)createTextView:(NSString *)name tag:(NSInteger)tag {

    UITextView *textView = [[UITextView alloc] init];
    [textView setBackgroundColor:LIGHT_BG_COLOR];
    [textView setTextColor:DARK_TEXT_COLOR];
    [textView.layer setCornerRadius: DEF_CORNER_RADIUS];
    [textView.layer setBorderWidth: DEF_BORDER_WIDTH];
    [textView setTag: tag];
    [textView setTextAlignment:NSTextAlignmentLeft];
    [textView setFont:TEXT_FIELD_FONT];
    [textView setText:name];
    [textView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    
    return textView;
}

+ (UIPickerView *)createPickerView:(CGFloat)width tag:(NSInteger)tag {
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, width, DEF_PICKER_HEIGHT)];
    [pickerView setBackgroundColor: DARK_BG_COLOR];
    [pickerView setShowsSelectionIndicator:YES];
    [pickerView setTag:tag];
    
    return pickerView;
}

+ (UIPickerView *)createPickerView:(CGFloat)width tag:(NSInteger)tag xOffset:(CGFloat)x yOffset:(CGFloat)y {
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(x, y, width, DEF_PICKER_HEIGHT)];
    [pickerView setBackgroundColor: DARK_BG_COLOR];
    [pickerView setShowsSelectionIndicator:YES];
    [pickerView setTag:tag];
    
    return pickerView;
}

+ (void)makeTextFieldNonEditable:(UITextField *)refName content:(NSString *)content border:(BOOL)border {
    if (![content isEqualToString:@""]) {
        [refName setText:content];
    }
    
    [refName setFont:TEXT_FIELD_FONT];
    [refName setTextColor:LIGHT_TEXT_COLOR];
    [refName setBackgroundColor:DARK_BG_COLOR];
    
    if (border == TRUE) {
        [refName.layer setBorderWidth: DEF_BORDER_WIDTH];
        [refName.layer setCornerRadius: DEF_CORNER_RADIUS];
        [refName.layer setBorderColor:[GRAY_BORDER_COLOR CGColor]];
    }
    [refName setEnabled:FALSE];
}

+ (void)makeTextFieldEditable:(UITextField *)refName content:(NSString *)content {
    if (![content isEqualToString:@""]) {
        [refName setText:content];
    }
    
    [refName setFont:TEXT_FIELD_FONT];
    [refName setTextColor:DARK_TEXT_COLOR];
    [refName setBackgroundColor:LIGHT_BG_COLOR];
    
    [refName setEnabled:TRUE];
}

+ (void)makeTextViewNonEditable:(UITextView *)refName content:(NSString *)content border:(BOOL)border {
    if (![content isEqualToString:@""]) {
        [refName setText:content];
    }
    
    [refName setFont:TEXT_FIELD_FONT];
    [refName setTextColor:LIGHT_TEXT_COLOR];
    [refName setBackgroundColor:DARK_BG_COLOR];
    
    if (border == TRUE) {
        [refName.layer setBorderWidth: DEF_BORDER_WIDTH];
        [refName.layer setCornerRadius: DEF_CORNER_RADIUS];
        [refName.layer setBorderColor:[GRAY_BORDER_COLOR CGColor]];
    }
    [refName setEditable:FALSE];
}

+ (void)makeTextViewEditable:(UITextView *)refName content:(NSString *)content {    
    if (![content isEqualToString:@""]) {
        [refName setText:content];
    }
    
    [refName setFont:TEXT_FIELD_FONT];
    [refName setTextColor:DARK_TEXT_COLOR];
    [refName setBackgroundColor:LIGHT_BG_COLOR];
    
    [refName setEditable:TRUE];
}

@end
