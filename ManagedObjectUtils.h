//
//  ManagedObjectUtils.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 1/23/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "SubjectiveColor.h"
#import "PaintSwatchType.h"
#import "PaintSwatches.h"
#import "Keyword.h"
#import "SwatchKeyword.h"
#import "MixAssociation.h"
#import "MixAssocKeyword.h"
#import "MatchAssociations.h"
#import "MatchAssocKeyword.h"
#import "MatchAlgorithm.h"

@interface ManagedObjectUtils : NSObject


// Init methods
//
+ (void)insertSubjectiveColors;
+ (void)insertPaintSwatchTypes;
+ (void)insertMatchAlgorithms;
+ (void)insertTestPaintSwatches:(NSManagedObjectContext *)context;

// Fetch methods
//
+ (int)fetchCount:(NSString *)entityName;
+ (NSArray *)fetchEntity:(NSString *)entityName context:(NSManagedObjectContext *)context;
+ (NSArray *)fetchKeywords:(NSManagedObjectContext *)context;
+ (NSMutableArray *)fetchPaintSwatches:(NSManagedObjectContext *)context;
+ (NSMutableArray *)fetchMixAssociations:(NSManagedObjectContext *)context;
+ (NSMutableArray *)fetchMatchAssociations:(NSManagedObjectContext *)context;
+ (NSMutableDictionary *)fetchSubjectiveColors:(NSManagedObjectContext *)context;
+ (NSMutableArray *)fetchDictNames:(NSString *)entityName context:(NSManagedObjectContext *)context;

// Generic query methods
//
+ (id)queryObjectKeyword:(NSManagedObjectID *)keyword_id objId:(NSManagedObjectID *)obj_id relationName:(NSString *)relationName entityName:(NSString *)entityName context:(NSManagedObjectContext *)context;
+ (NSArray *)queryObjectKeywords:(NSManagedObjectID *)obj_id relationName:(NSString *)relationName entityName:(NSString *)entityName context:(NSManagedObjectContext *)context;

// Specific query methods
//
+ (NSMutableArray *)queryMixAssocSwatches:(NSManagedObjectID *)mix_assoc_id context:(NSManagedObjectContext *)context;
+ (NSMutableArray *)queryTapAreas:(NSManagedObjectID *)match_assoc_id context:(NSManagedObjectContext *)context;
+ (SubjectiveColor *)querySubjectiveColor:(NSString *)colorName context:(NSManagedObjectContext *)context;
+ (SubjectiveColor *)querySubjectiveColorByOrder:(NSNumber *)order context:(NSManagedObjectContext *)context;
+ (PaintSwatches *)queryPaintSwatches:(NSString *)swatchName context:(NSManagedObjectContext *)context;
+ (Keyword *)queryKeyword:(NSString *)keyword context:(NSManagedObjectContext *)context;
+ (MixAssociation *)queryMixAssociation:(int)mix_assoc_id context:(NSManagedObjectContext *)context;
+ (NSMutableArray *)queryMixAssocBySwatch:(NSManagedObjectID *)swatch_id context:(NSManagedObjectContext *)context;

// Delete methods
//
+ (void)deleteSwatchKeywords:(PaintSwatches *)swatchObj context:(NSManagedObjectContext *)context;
+ (void)deleteMatchAssocKeywords:(MatchAssociations *)matchAssocObj context:(NSManagedObjectContext *)context;
+ (void)deleteMixAssocKeywords:(MixAssociation *)mixAssocObj context:(NSManagedObjectContext *)context;

@end
