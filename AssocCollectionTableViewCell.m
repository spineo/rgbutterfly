//
//  AssocCollectionTableViewCell.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 7/13/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "AssocCollectionTableViewCell.h"
#import "GlobalSettings.h"
#import "FieldUtils.h"

@interface AssocCollectionTableViewCell()

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@end

@implementation AssocCollectionTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    _layout = [[UICollectionViewFlowLayout alloc] init];
    [_layout setSectionInset: UIEdgeInsetsMake(DEF_COLLECTVIEW_INSET*2.0, DEF_FIELD_PADDING, DEF_COLLECTVIEW_INSET, DEF_FIELD_PADDING)];
    [_layout setMinimumInteritemSpacing:DEF_FIELD_PADDING];
    [_layout setItemSize: CGSizeMake(DEF_TABLE_CELL_HEIGHT, DEF_TABLE_CELL_HEIGHT)];
    [_layout setScrollDirection: UICollectionViewScrollDirectionHorizontal];
    [_layout setHeaderReferenceSize:CGSizeMake(DEF_FIELD_PADDING, DEF_FIELD_PADDING)];

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
    [self.collectionView setBackgroundColor: DARK_BG_COLOR];
    [self.collectionView setShowsHorizontalScrollIndicator: NO];

    [self.contentView addSubview:self.collectionView];
    
    return self;
}

- (void)setAssocName:(NSString *)desc {
    UILabel *assocDesc = [FieldUtils createSmallLabel:desc xOffset:DEF_TABLE_X_OFFSET yOffset:DEF_Y_OFFSET];
    [assocDesc setBackgroundColor: DARK_BG_COLOR];

    [self.contentView addSubview:assocDesc];
}

- (void)setNoLabelLayout {
    [self.layout setSectionInset: UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.collectionView setFrame: self.contentView.bounds];
}

// TableView controller will handle the Collection methods
//
- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index {
    [self.collectionView setDataSource: dataSourceDelegate];
    [self.collectionView setDelegate: dataSourceDelegate];
    [self.collectionView setTag: index];
    
    [self.collectionView reloadData];
}


@end
