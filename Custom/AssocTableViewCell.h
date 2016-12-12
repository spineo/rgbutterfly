//
//  AssocTableViewCell.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 4/18/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *assocCellIdentifier = @"AssocCellIdentifier";

@interface AssocTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic) BOOL textReturn;
@property (nonatomic, strong) NSString *textEntered;
@property (nonatomic, strong) UITextField *mixName;

@end
