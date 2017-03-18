//
//  MatchAssociations+CoreDataProperties.h
//  RGButterfly
//
//  Created by Stuart Pineo on 3/7/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MatchAssociations.h"

NS_ASSUME_NONNULL_BEGIN

@interface MatchAssociations (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *create_date;
@property (nullable, nonatomic, retain) NSString *desc;
@property (nonatomic, retain) id image_url;
@property (nullable, nonatomic, retain) NSDate *last_update;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *version_tag;
@property (nonatomic, retain) NSSet<TapArea *> *tap_area;
@property (nonatomic, retain) NSSet<MatchAssocKeyword *> *match_assoc_keyword;

@end

@interface MatchAssociations (CoreDataGeneratedAccessors)

- (void)addTap_areaObject:(TapArea *)value;
- (void)removeTap_areaObject:(TapArea *)value;
- (void)addTap_area:(NSSet<TapArea *> *)values;
- (void)removeTap_area:(NSSet<TapArea *> *)values;

- (void)addMatch_assoc_keywordObject:(MatchAssocKeyword *)value;
- (void)removeMatch_assoc_keywordObject:(MatchAssocKeyword *)value;
- (void)addMatch_assoc_keyword:(NSSet<MatchAssocKeyword *> *)values;
- (void)removeMatch_assoc_keyword:(NSSet<MatchAssocKeyword *> *)values;

@end

NS_ASSUME_NONNULL_END
