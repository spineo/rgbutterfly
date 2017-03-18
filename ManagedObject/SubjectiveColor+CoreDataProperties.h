//
//  SubjectiveColor+CoreDataProperties.h
//  RGButterfly
//
//  Created by Stuart Pineo on 1/25/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SubjectiveColor.h"

NS_ASSUME_NONNULL_BEGIN

@interface SubjectiveColor (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *hex_value;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *order;
@property (nullable, nonatomic, retain) NSSet<PaintSwatches *> *paint_swatch;

@end

@interface SubjectiveColor (CoreDataGeneratedAccessors)

- (void)addPaint_swatchObject:(PaintSwatches *)value;
- (void)removePaint_swatchObject:(PaintSwatches *)value;
- (void)addPaint_swatch:(NSSet<PaintSwatches *> *)values;
- (void)removePaint_swatch:(NSSet<PaintSwatches *> *)values;

@end

NS_ASSUME_NONNULL_END
