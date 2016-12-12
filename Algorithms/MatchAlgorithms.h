//
//  MatchAlgorithms.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 9/6/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaintSwatches.h"

@interface MatchAlgorithms : NSObject

+ (float)colorDiffAlgorithm0:(PaintSwatches *)mainObj compObj:(PaintSwatches *)compObj;
+ (float)colorDiffAlgorithm1:(PaintSwatches *)mainObj compObj:(PaintSwatches *)compObj;
+ (float)colorDiffAlgorithm2:(PaintSwatches *)mainObj compObj:(PaintSwatches *)compObj;
+ (float)colorDiffAlgorithm3:(PaintSwatches *)mainObj compObj:(PaintSwatches *)compObj;
+ (float)colorDiffAlgorithm4:(PaintSwatches *)mainObj compObj:(PaintSwatches *)compObj;
+ (float)colorDiffAlgorithm5:(PaintSwatches *)mainObj compObj:(PaintSwatches *)compObj;
+ (float)colorDiffAlgorithm6:(PaintSwatches *)mainObj compObj:(PaintSwatches *)compObj;
+ (NSMutableArray *)sortByClosestMatch:(PaintSwatches *)refObj swatches:(NSMutableArray *)swatches matchAlgorithm:(int)matchAlgIndex maxMatchNum:(int)maxMatchNum context:(NSManagedObjectContext *)context entity:(NSEntityDescription *)entity;

@end
