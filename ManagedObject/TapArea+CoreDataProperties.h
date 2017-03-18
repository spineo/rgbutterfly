//
//  TapArea+CoreDataProperties.h
//  RGButterfly
//
//  Created by Stuart Pineo on 3/7/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TapArea.h"

NS_ASSUME_NONNULL_BEGIN

@interface TapArea (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSNumber *tap_order;
@property (nonatomic, retain) NSString *coord_pt;
@property (nonatomic, retain) id image_section;
@property (nullable, nonatomic, retain) NSNumber *ma_manual_override;
@property (nonatomic, retain) NSNumber *match_algorithm_id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *version_tag;
@property (nonatomic, retain) MatchAssociations *match_association;
@property (nullable, nonatomic, retain) NSSet<TapAreaKeyword *> *tap_area_keyword;
@property (nonatomic, retain) NSSet<TapAreaSwatch *> *tap_area_swatch;
@property (nonatomic, retain) PaintSwatches *tap_area_match;

@end

@interface TapArea (CoreDataGeneratedAccessors)

- (void)addTap_area_keywordObject:(TapAreaKeyword *)value;
- (void)removeTap_area_keywordObject:(TapAreaKeyword *)value;
- (void)addTap_area_keyword:(NSSet<TapAreaKeyword *> *)values;
- (void)removeTap_area_keyword:(NSSet<TapAreaKeyword *> *)values;

- (void)addTap_area_swatchObject:(TapAreaSwatch *)value;
- (void)removeTap_area_swatchObject:(TapAreaSwatch *)value;
- (void)addTap_area_swatch:(NSSet<TapAreaSwatch *> *)values;
- (void)removeTap_area_swatch:(NSSet<TapAreaSwatch *> *)values;

@end

NS_ASSUME_NONNULL_END
