//
//  PaintSwatchType+CoreDataProperties.h
//  RGButterfly
//
//  Created by Stuart Pineo on 2/27/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PaintSwatchType.h"

NS_ASSUME_NONNULL_BEGIN

@interface PaintSwatchType (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *order;

@end

NS_ASSUME_NONNULL_END
