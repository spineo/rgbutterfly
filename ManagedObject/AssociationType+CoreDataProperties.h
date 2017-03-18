//
//  AssociationType+CoreDataProperties.h
//  RGButterfly
//
//  Created by Stuart Pineo on 10/6/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import "AssociationType+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface AssociationType (CoreDataProperties)

+ (NSFetchRequest<AssociationType *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber *order;

@end

NS_ASSUME_NONNULL_END
