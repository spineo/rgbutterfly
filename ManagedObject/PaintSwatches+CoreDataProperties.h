//
//  PaintSwatches+CoreDataProperties.h
//  RGButterfly
//
//  Created by Stuart Pineo on 1/25/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PaintSwatches.h"

NS_ASSUME_NONNULL_BEGIN

@interface PaintSwatches (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *abbr_name;
@property (nullable, nonatomic, retain) NSString *alpha;
@property (nullable, nonatomic, retain) NSString *blue;
@property (nullable, nonatomic, retain) NSNumber *body_type_id;
@property (nullable, nonatomic, retain) NSString *brightness;
@property (nullable, nonatomic, retain) NSString *coord_pt;
@property (nullable, nonatomic, retain) NSNumber *coverage_id;
@property (nullable, nonatomic, retain) NSDate *create_date;
@property (nullable, nonatomic, retain) NSNumber *deg_hue;
@property (nullable, nonatomic, retain) NSString *desc;
@property (nullable, nonatomic, retain) NSString *green;
@property (nullable, nonatomic, retain) NSString *hue;
@property (nullable, nonatomic, retain) NSNumber *is_shipped;
@property (nullable, nonatomic, retain) NSNumber *is_hidden;
@property (nullable, nonatomic, retain) NSNumber *is_readonly;
@property (nullable, nonatomic, retain) id image_thumb;
@property (nullable, nonatomic, retain) NSNumber *is_mix;
@property (nullable, nonatomic, retain) NSDate *last_update;
@property (nullable, nonatomic, retain) NSNumber *mix_parts_ratio;
@property (nullable, nonatomic, retain) NSNumber *mix_swatch_id;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *pigment_type_id;
@property (nullable, nonatomic, retain) NSNumber *paint_brand_id;
@property (nullable, nonatomic, retain) NSString *paint_brand_name;
@property (nullable, nonatomic, retain) NSString *red;
@property (nullable, nonatomic, retain) NSNumber *ref_parts_ratio;
@property (nullable, nonatomic, retain) NSNumber *ref_swatch_id;
@property (nullable, nonatomic, retain) NSString *saturation;
@property (nullable, nonatomic, retain) NSNumber *subj_color_id;
@property (nullable, nonatomic, retain) NSNumber *type_id;
@property (nullable, nonatomic, retain) NSNumber *version_tag;
@property (nullable, nonatomic, retain) NSSet<MixAssocSwatch *> *mix_assoc_swatch;
@property (nullable, nonatomic, retain) SubjectiveColor *subjective_color;
@property (nullable, nonatomic, retain) NSSet<SwatchKeyword *> *swatch_keyword;
@property (nullable, nonatomic, retain) NSSet<TapAreaSwatch *> *tap_area_swatch;
@property (nullable, nonatomic, retain) TapArea *tap_area;

@property (nonatomic) BOOL is_selected;

@end

@interface PaintSwatches (CoreDataGeneratedAccessors)

- (void)addMix_assoc_swatchObject:(MixAssocSwatch *)value;
- (void)removeMix_assoc_swatchObject:(MixAssocSwatch *)value;
- (void)addMix_assoc_swatch:(NSSet<MixAssocSwatch *> *)values;
- (void)removeMix_assoc_swatch:(NSSet<MixAssocSwatch *> *)values;

- (void)addSwatch_keywordObject:(SwatchKeyword *)value;
- (void)removeSwatch_keywordObject:(SwatchKeyword *)value;
- (void)addSwatch_keyword:(NSSet<SwatchKeyword *> *)values;
- (void)removeSwatch_keyword:(NSSet<SwatchKeyword *> *)values;

- (void)addTap_area_swatchObject:(TapAreaSwatch *)value;
- (void)removeTap_area_swatchObject:(TapAreaSwatch *)value;
- (void)addTap_area_swatch:(NSSet<TapAreaSwatch *> *)values;
- (void)removeTap_area_swatch:(NSSet<TapAreaSwatch *> *)values;

@end

NS_ASSUME_NONNULL_END
