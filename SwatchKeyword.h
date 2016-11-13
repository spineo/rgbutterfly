//
//  SwatchKeyword.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 1/18/16.
//  Copyright (c) 2016 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Keyword, PaintSwatch;

@interface SwatchKeyword : NSManagedObject

@property (nonatomic, retain) NSNumber *version;
@property (nonatomic, retain) Keyword *keyword;
@property (nonatomic, retain) PaintSwatch *paint_swatch;

@end
