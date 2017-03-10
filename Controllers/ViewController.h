//
//  ViewController.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 2/26/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "UIImageViewController.h"
#import "GlobalSettings.h"
#import "AppColorUtils.h"
#import "ColorUtils.h"


@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate>

@property (nonatomic) int imageAction;
@property (nonatomic, strong) NSMutableArray *paintSwatches;
@property (nonatomic, strong) PaintSwatches *selPaintSwatch;
@property (nonatomic, strong) NSArray *subjColorNames, *keywordsIndexTitles;

@property (nonatomic, strong) IBOutlet UITableView *colorTableView;

@end
