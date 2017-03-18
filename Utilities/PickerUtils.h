//
//  PickerUtils.h
//  RGButterfly
//
//  Created by Stuart Pineo on 6/20/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PickerUtils : UIPickerView

+ (UIPickerView *)createPicker:(id)sender tag:(int)pickerTag selectRow:(int)selectRow action:(SEL)action textField:(UITextField *)textField;
+ (UIView *)addPickerDone:(id)sender picker:(UIPickerView *)picker action:(SEL)action textField:(UITextField *)textField;

@end
