//
//  AssocCollectionTableViewCell.m
//  RGButterfly
//
//  Created by Stuart Pineo on 7/13/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "AssocCollectionTableViewCell.h"
#import "GlobalSettings.h"
#import "FieldUtils.h"

@interface CustomCollectionTableViewCell()

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@end

@implementation CustomCollectionTableViewCell


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
    [self.collectionView setBackgroundColor:DARK_BG_COLOR];
    [self.collectionView setShowsHorizontalScrollIndicator:NO];

    [self.contentView addSubview:self.collectionView];
    
    return self;
}

- (void)setAssocName:(NSString *)desc {
    UILabel *assocDesc = [FieldUtils createLabel:desc xOffset:DEF_TABLE_X_OFFSET yOffset:DEF_Y_OFFSET width:self.contentView.bounds.size.width height:DEF_LABEL_HEIGHT];
    [assocDesc setBackgroundColor: DARK_BG_COLOR];

    [self.contentView addSubview:assocDesc];
}

- (void)setNoLabelLayout {
    [self.layout setSectionInset:UIEdgeInsetsMake(DEF_X_OFFSET, DEF_Y_OFFSET, DEF_NIL_WIDTH, DEF_NIL_HEIGHT)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (! _xOffset) {
        _xOffset = self.contentView.bounds.origin.x;
    }

    [self.collectionView setFrame:CGRectMake(_xOffset, self.contentView.bounds.origin.y, self.contentView.bounds.size.width, self.contentView.bounds.size.height)];
    
    CGFloat yCrop  = (self.contentView.bounds.size.height - DEF_TABLE_CELL_HEIGHT) / 2.0;
    CGFloat offset = DEF_FIELD_PADDING * 2.0;

    [self.imageView setFrame:CGRectMake(offset, self.contentView.bounds.origin.y + offset, DEF_TABLE_CELL_HEIGHT, self.contentView.bounds.size.height)];
    self.imageView.bounds = CGRectInset(self.imageView.frame, DEF_NIL_WIDTH, yCrop);
}

// TableView controller will handle the Collection methods
//
- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index {
    [self.collectionView setDataSource:dataSourceDelegate];
    [self.collectionView setDelegate:dataSourceDelegate];
    [self.collectionView setTag:index];
    
    [self.collectionView reloadData];
}


@end
