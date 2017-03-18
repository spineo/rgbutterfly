//
//  BodyType+CoreDataProperties.h
//  RGButterfly
//
//  Created by Stuart Pineo on 5/29/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "BodyType.h"

NS_ASSUME_NONNULL_BEGIN

@interface BodyType (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *order;

@end

NS_ASSUME_NONNULL_END
