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
#import "MixAssocSwatch.h"
#import "MixAssocKeyword.h"
#import "MatchAssociations.h"
#import "MatchAssocKeyword.h"
#import "TapArea.h"
#import "TapAreaKeyword.h"
#import "MatchAlgorithm.h"

@interface ManagedObjectUtils : NSObject


// Init methods
//
+ (void)insertSubjectiveColors;
+ (void)insertFromDataFile:(NSString *)entityName;
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
+ (NSMutableDictionary *)fetchDictByNames:(NSString *)entityName context:(NSManagedObjectContext *)context;

// Generic query methods
//
+ (id)queryObjectKeyword:(NSManagedObjectID *)keyword_id objId:(NSManagedObjectID *)obj_id relationName:(NSString *)relationName entityName:(NSString *)entityName context:(NSManagedObjectContext *)context;
+ (NSArray *)queryEntityRelation:(NSManagedObjectID *)obj_id relationName:(NSString *)relationName entityName:(NSString *)entityName context:(NSManagedObjectContext *)context;
+ (id)queryDictionaryName:(NSString *)entityName entityId:(int)entityId context:(NSManagedObjectContext *)context;
+ (id)queryDictionaryByNameValue:(NSString *)entityName nameValue:(NSString *)nameValue context:(NSManagedObjectContext *)context;

// Specific query methods
//
+ (NSMutableArray *)queryMixAssocSwatches:(NSManagedObjectID *)mix_assoc_id context:(NSManagedObjectContext *)context;
+ (NSMutableArray *)queryTapAreas:(NSManagedObjectID *)match_assoc_id context:(NSManagedObjectContext *)context;
+ (SubjectiveColor *)querySubjectiveColor:(NSString *)colorName context:(NSManagedObjectContext *)context;
+ (SubjectiveColor *)querySubjectiveColorByOrder:(NSNumber *)order context:(NSManagedObjectContext *)context;
+ (PaintSwatches *)queryPaintSwatches:(NSString *)swatchName context:(NSManagedObjectContext *)context;
+ (NSArray *)queryPaintSwatchesBySubjColorId:(int)subj_color_id context:(NSManagedObjectContext *)context;
+ (Keyword *)queryKeyword:(NSString *)keyword context:(NSManagedObjectContext *)context;
+ (MixAssociation *)queryMixAssociation:(int)mix_assoc_id context:(NSManagedObjectContext *)context;
+ (NSMutableArray *)queryMixAssocBySwatch:(NSManagedObjectID *)swatch_id context:(NSManagedObjectContext *)context;

// Update methods
//
+ (void)setEntityReadOnly:(NSString *)entityName isReadOnly:(BOOL)is_readonly context:(NSManagedObjectContext *)context;

// Delete methods
//
+ (void)deleteDictionaryEntity:(NSString *)entityName;
+ (void)deleteSwatchKeywords:(PaintSwatches *)swatchObj context:(NSManagedObjectContext *)context;
+ (void)deleteTapAreaKeywords:(TapArea *)tapAreaObj context:(NSManagedObjectContext *)context;
+ (void)deleteMatchAssocKeywords:(MatchAssociations *)matchAssocObj context:(NSManagedObjectContext *)context;
+ (void)deleteMixAssocKeywords:(MixAssociation *)mixAssocObj context:(NSManagedObjectContext *)context;
+ (void)deletePaintSwatchKeywords:(PaintSwatches *)paintSwatchObj context:(NSManagedObjectContext *)context;
+ (void)deleteMixAssociation:(MixAssociation *)mixAssocObj context:(NSManagedObjectContext *)context;

// Cleanup methods
//
+ (void)deleteOrphanPaintSwatches:(NSManagedObjectContext *)context;
+ (void)deleteChildlessMatchAssoc:(NSManagedObjectContext *)context;
+ (void)deleteChildlessMixAssoc:(NSManagedObjectContext *)context;

@end
