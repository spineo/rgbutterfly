//
//  MatchTableViewController.h
//  RGButterfly
//
//  Created by Stuart Pineo on 8/25/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintSwatches.h"
#import "TapArea.h"

@interface MatchTableViewController : UITableViewController <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) PaintSwatches *selPaintSwatch;
@property (nonatomic) int currTapSection, matchAlgIndex, maxMatchNum;
@property (nonatomic, strong) UIImage *referenceImage;
@property (nonatomic, strong) NSMutableArray *dbPaintSwatches;
@property (nonatomic, strong) NSArray *tapSections;
@property (nonatomic, strong) TapArea *tapArea;
@property (nonatomic) BOOL maManualOverride;
@property (nonatomic, strong) MatchAssociations *matchAssociation;

@end
