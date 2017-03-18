//
//  MixAssocKeyword+CoreDataProperties.h
//  RGButterfly
//
//  Created by Stuart Pineo on 4/3/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MixAssocKeyword.h"

NS_ASSUME_NONNULL_BEGIN

@interface MixAssocKeyword (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *version_tag;
@property (nullable, nonatomic, retain) Keyword *keyword;
@property (nullable, nonatomic, retain) MixAssociation *mix_association;

@end

NS_ASSUME_NONNULL_END
