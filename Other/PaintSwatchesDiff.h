//
//  PaintSwatchesDiff.h
//  RGButterfly
//
//  Created by Stuart Pineo on 9/7/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaintSwatchesDiff : NSObject

@property (nonatomic) float diff;
@property (nonatomic) int index;
@property (nonatomic, strong) NSString *name;

@end
