//
//  AssocCollectionTableViewCell.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 7/13/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface AssocCollectionTableViewCell : UITableViewCell

@property (nonatomic, strong) UICollectionView *collectionView;

- (void)setAssocName:(NSString *)desc;
- (void)setNoLabelLayout;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index;

@end