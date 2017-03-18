//
//  AssociationType+CoreDataProperties.m
//  RGButterfly
//
//  Created by Stuart Pineo on 10/6/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import "AssociationType+CoreDataProperties.h"

@implementation AssociationType (CoreDataProperties)

+ (NSFetchRequest<AssociationType *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"AssociationType"];
}

@dynamic name;
@dynamic order;

@end
