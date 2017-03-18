//
//  TapAreaKeyword.h
//  RGButterfly
//
//  Created by Stuart Pineo on 1/18/16.
//  Copyright (c) 2016 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Keyword, TapArea;

@interface TapAreaKeyword : NSManagedObject

@property (nonatomic, retain) NSNumber *version_tag;
@property (nonatomic, retain) Keyword *keyword;
@property (nonatomic, retain) TapArea *tap_area;

@end
