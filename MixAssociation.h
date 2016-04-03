//
//  MixAssociation.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 1/18/16.
//  Copyright (c) 2016 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MixAssocSwatch, MixAssocKeyword;

@interface MixAssociation : NSManagedObject

@property (nonatomic, retain) NSDate * create_date;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) id image_url;
@property (nonatomic, retain) NSDate * last_update;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *mix_assoc_swatch;
@property (nonatomic, retain) NSSet *mix_assoc_keyword;

@end

@interface MixAssociation (CoreDataGeneratedAccessors)

- (void)addMix_assoc_swatchObject:(MixAssocSwatch *)value;
- (void)removeMix_assoc_swatchObject:(MixAssocSwatch *)value;
- (void)addMix_assoc_swatch:(NSSet *)values;
- (void)removeMix_assoc_swatch:(NSSet *)values;

- (void)addMix_assoc_keywordObject:(MixAssocKeyword *)value;
- (void)removeMix_assoc_keywordObject:(MixAssocKeyword *)value;
- (void)addMix_assoc_keyword:(NSSet<MixAssocKeyword *> *)values;
- (void)removeMix_assoc_keyword:(NSSet<MixAssocKeyword *> *)values;

@end
