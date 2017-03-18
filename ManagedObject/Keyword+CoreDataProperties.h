//
//  KeywordNames+CoreDataProperties.h
//  RGButterfly
//
//  Created by Stuart Pineo on 4/3/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Keyword.h"

NS_ASSUME_NONNULL_BEGIN

@interface Keyword (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *version_tag;
@property (nullable, nonatomic, retain) NSSet<MatchAssocKeyword *> *match_assoc_keyword;
@property (nullable, nonatomic, retain) NSSet<MixAssocKeyword *> *mix_assoc_keyword;
@property (nullable, nonatomic, retain) NSSet<SwatchKeyword *> *swatch_keyword;
@property (nullable, nonatomic, retain) NSSet<TapAreaKeyword *> *tap_area_keyword;

@end

@interface Keyword (CoreDataGeneratedAccessors)

- (void)addMatch_assoc_keywordObject:(MatchAssocKeyword *)value;
- (void)removeMatch_assoc_keywordObject:(MatchAssocKeyword *)value;
- (void)addMatch_assoc_keyword:(NSSet<MatchAssocKeyword *> *)values;
- (void)removeMatch_assoc_keyword:(NSSet<MatchAssocKeyword *> *)values;

- (void)addMix_assoc_keywordObject:(MixAssocKeyword *)value;
- (void)removeMix_assoc_keywordObject:(MixAssocKeyword *)value;
- (void)addMix_assoc_keyword:(NSSet<MixAssocKeyword *> *)values;
- (void)removeMix_assoc_keyword:(NSSet<MixAssocKeyword *> *)values;

- (void)addSwatch_keywordObject:(SwatchKeyword *)value;
- (void)removeSwatch_keywordObject:(SwatchKeyword *)value;
- (void)addSwatch_keyword:(NSSet<SwatchKeyword *> *)values;
- (void)removeSwatch_keyword:(NSSet<SwatchKeyword *> *)values;

- (void)addTap_area_keywordObject:(TapAreaKeyword *)value;
- (void)removeTap_area_keywordObject:(TapAreaKeyword *)value;
- (void)addTap_area_keyword:(NSSet<TapAreaKeyword *> *)values;
- (void)removeTap_area_keyword:(NSSet<TapAreaKeyword *> *)values;

@end

NS_ASSUME_NONNULL_END
