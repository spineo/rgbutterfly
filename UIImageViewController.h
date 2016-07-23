//
//  UIImageViewController.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 3/7/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

// NSManagedObject
//
#import "MixAssociation.h"
#import "MatchAssociations.h"


@interface UIImageViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *imageScrollView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) NSMutableArray *paintSwatches;
@property (nonatomic, strong) NSString *sourceViewContext, *viewType;

// Entities
//
@property (nonatomic, strong) MixAssociation *mixAssociation;
@property (nonatomic, strong) MatchAssociations *matchAssociation;

@property (nonatomic, strong) IBOutlet UITableView *imageTableView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *scrollHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageViewToSuperviewTop;

@end
