//
//  MatchAlgorithm+CoreDataProperties.h
//  RGButterfly
//
//  Created by Stuart Pineo on 3/16/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MatchAlgorithm.h"

NS_ASSUME_NONNULL_BEGIN

@interface MatchAlgorithm (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *order;

@end

NS_ASSUME_NONNULL_END
