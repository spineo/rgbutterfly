//
//  MatchTableViewController.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 8/25/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintSwatches.h"

@interface MatchTableViewController : UITableViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) PaintSwatches *selPaintSwatch;
@property (nonatomic) int currTapSection, matchAlgIndex, maxMatchNum;
@property (nonatomic, strong) UIImage *referenceImage;
@property (nonatomic, strong) NSMutableArray *dbPaintSwatches;

@end
