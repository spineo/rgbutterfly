//
//  CanvasCoverage+CoreDataProperties.m
//  RGButterfly
//
//  Created by Stuart Pineo on 9/2/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import "CanvasCoverage+CoreDataProperties.h"

@implementation CanvasCoverage (CoreDataProperties)

+ (NSFetchRequest<CanvasCoverage *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CanvasCoverage"];
}

@dynamic name;
@dynamic order;

@end
