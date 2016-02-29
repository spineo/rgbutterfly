//
//  KeywordNames.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 1/18/16.
//  Copyright (c) 2016 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SwatchKeyword, TapAreaKeyword;

@interface Keyword : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *swatch_keyword;
@property (nonatomic, retain) NSSet *tap_area_keyword;
@end

@interface Keyword (CoreDataGeneratedAccessors)

- (void)addSwatch_keywordObject:(SwatchKeyword *)value;
- (void)removeSwatch_keywordObject:(SwatchKeyword *)value;
- (void)addSwatch_keyword:(NSSet *)values;
- (void)removeSwatch_keyword:(NSSet *)values;

- (void)addTap_area_keywordObject:(TapAreaKeyword *)value;
- (void)removeTap_area_keywordObject:(TapAreaKeyword *)value;
- (void)addTap_area_keyword:(NSSet *)values;
- (void)removeTap_area_keyword:(NSSet *)values;

@end
