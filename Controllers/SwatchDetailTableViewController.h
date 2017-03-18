//
//  SwatchDetailTableViewController.h
//  RGButterfly
//
//  Created by Stuart Pineo on 6/15/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintSwatches.h"


@interface SwatchDetailTableViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) PaintSwatches *paintSwatch, *refPaintSwatch, *mixPaintSwatch;
@property (nonatomic, strong) NSMutableArray *mixAssocSwatches;

extern const int DETAIL_MAX_SECTION;

@end
