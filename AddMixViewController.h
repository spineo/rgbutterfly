//
//  AddMixViewController.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 5/30/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintSwatches.h"

@interface AddMixViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property NSMutableArray *paintSwatches, *addPaintSwatches;

@property NSString *reuseCellIdentifier, *searchString;

@property BOOL isRGB, searchMatch;

@property UIColor *defaultColor, *defaultBgColor,  *currColor;
@property UIFont *defaultFont, *placeholderFont, *currFont;
@property UILabel *mixTitleLabel;
@property NSString *domColorLabel, *mixColorLabel, *addColorLabel;
@property CGColorRef defColorBorder;
@property CGFloat defCellHeight;
@property UIView *bgColorView;
@property UIImage *colorRenderingImage;

// SearchBar related
//
@property UIView *titleView;
@property (strong, nonatomic) UISearchBar *mixSearchBar;

@property (weak, nonatomic) IBOutlet UITableView *addMixTableView;

- (IBAction)searchMix:(id)sender;

@end
