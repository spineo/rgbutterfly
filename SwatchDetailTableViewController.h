//
//  SwatchDetailTableViewController.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 6/15/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintSwatches.h"


@interface SwatchDetailTableViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) PaintSwatches *paintSwatch;
@property (nonatomic, strong) NSMutableArray *mixAssocSwatches;

@end
