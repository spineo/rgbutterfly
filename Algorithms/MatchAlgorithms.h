//
//  MatchAlgorithms.h
//  RGButterfly
//
//  Created by Stuart Pineo on 9/6/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaintSwatches.h"

@interface MatchAlgorithms : NSObject

+ (NSMutableArray *)sortByClosestMatch:(PaintSwatches *)refObj swatches:(NSMutableArray *)swatches matchAlgorithm:(int)matchAlgIndex maxMatchNum:(int)maxMatchNum context:(NSManagedObjectContext *)context entity:(NSEntityDescription *)entity;

@end
