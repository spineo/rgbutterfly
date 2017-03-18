//
//  MixAssocSwatch.h
//  RGButterfly
//
//  Created by Stuart Pineo on 1/18/16.
//  Copyright (c) 2016 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MixAssociation, PaintSwatch;

@interface MixAssocSwatch : NSManagedObject

@property (nonatomic, retain) NSNumber *mix_order;
@property (nonatomic, retain) NSNumber *paint_swatch_is_add;
@property (nonatomic, retain) NSNumber *version_tag;
@property (nonatomic, retain) MixAssociation *mix_association;
@property (nonatomic, retain) PaintSwatch *paint_swatch;

@end
