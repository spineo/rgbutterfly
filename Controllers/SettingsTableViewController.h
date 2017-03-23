//
//  SettingsTableViewController.h
//  RGButterfly
//
//  Created by Stuart Pineo on 5/9/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SettingsTableViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate>

// Set for unit testing visibility
//
extern const int SETTINGS_MAX_SECTIONS;

@end
