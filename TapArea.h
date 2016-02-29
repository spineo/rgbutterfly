//
//  TapArea.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 1/18/16.
//  Copyright (c) 2016 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MatchAssociation, TapAreaKeyword, TapAreaSwatch;

@interface TapArea : NSManagedObject

@property (nonatomic, retain) NSDate * create_date;
@property (nonatomic, retain) id image_section;
@property (nonatomic, retain) MatchAssociation *match_association;
@property (nonatomic, retain) NSSet *tap_area_keyword;
@property (nonatomic, retain) NSSet *tap_area_swatch;
@end

@interface TapArea (CoreDataGeneratedAccessors)

- (void)addTap_area_keywordObject:(TapAreaKeyword *)value;
- (void)removeTap_area_keywordObject:(TapAreaKeyword *)value;
- (void)addTap_area_keyword:(NSSet *)values;
- (void)removeTap_area_keyword:(NSSet *)values;

- (void)addTap_area_swatchObject:(TapAreaSwatch *)value;
- (void)removeTap_area_swatchObject:(TapAreaSwatch *)value;
- (void)addTap_area_swatch:(NSSet *)values;
- (void)removeTap_area_swatch:(NSSet *)values;

@end
