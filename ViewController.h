//
//  ViewController.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 2/26/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "GlobalSettings.h"
#import "ColorUtils.h"
#import "UIImageViewController.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic) int imageAction;
@property (nonatomic, strong) NSMutableArray *paintSwatches;
@property (nonatomic, strong) PaintSwatches *selPaintSwatch;
@property (nonatomic) BOOL isRGB;

@property (nonatomic, strong) IBOutlet UITableView *colorTableView;

- (IBAction)changeButtonRendering:(id)sender;

- (IBAction)showListingOptions:(id)sender;

@end
