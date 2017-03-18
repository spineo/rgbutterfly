//
//  CanvasCoverage+CoreDataProperties.h
//  RGButterfly
//
//  Created by Stuart Pineo on 9/2/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import "CanvasCoverage+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CanvasCoverage (CoreDataProperties)

+ (NSFetchRequest<CanvasCoverage *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber *order;

@end

NS_ASSUME_NONNULL_END
