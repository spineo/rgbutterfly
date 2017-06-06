//
//  AssocTableViewController.h
//  RGButterfly
//
//  Created by Stuart Pineo on 4/7/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewController.h"
#import "MixAssociation.h"
#import "GlobalSettings.h"
#import "BarButtonUtils.h"

@interface AssocTableViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate,NSFetchedResultsControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate>


// Set this value to determine the 'go back' action based on the source view controller
//
@property (nonatomic, strong) NSString *sourceViewName;

@property (nonatomic, strong) NSMutableArray *paintSwatches;

@property (nonatomic, strong) MixAssociation *mixAssociation;

@property (nonatomic) BOOL saveFlag;

// This name can be commonly applied to all mixes (but customized individually at the detail level)
//
@property (nonatomic, strong) UITextField *mixName;

@end
