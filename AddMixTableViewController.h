//
//  AddMixTableTableViewController.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 6/9/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintSwatches.h"

@interface AddMixTableViewController : UITableViewController <UISearchBarDelegate>

- (IBAction)searchMix:(id)sender;

@property NSMutableArray *paintSwatches, *addPaintSwatches;

@property NSString *reuseCellIdentifier, *searchString;

@property BOOL isRGB, searchMatch;


@end