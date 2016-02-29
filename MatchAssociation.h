//
//  MatchAssociations.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 1/18/16.
//  Copyright (c) 2016 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TapArea;

@interface MatchAssociation : NSManagedObject

@property (nonatomic, retain) NSDate * create_date;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) id image_url;
@property (nonatomic, retain) NSDate * last_update;
@property (nonatomic, retain) NSNumber * ma_manual_override;
@property (nonatomic, retain) NSNumber * match_algorithm_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *tap_area;
@end

@interface MatchAssociation (CoreDataGeneratedAccessors)

- (void)addTap_areaObject:(TapArea *)value;
- (void)removeTap_areaObject:(TapArea *)value;
- (void)addTap_area:(NSSet *)values;
- (void)removeTap_area:(NSSet *)values;

@end
