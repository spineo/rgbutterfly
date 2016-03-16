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

// Query methods
//
+ (NSMutableArray *)queryMixAssocSwatches:(NSManagedObjectID *)mix_assoc_id context:(NSManagedObjectContext *)context;
+ (NSMutableArray *)queryTapAreas:(NSManagedObjectID *)match_assoc_id context:(NSManagedObjectContext *)context;
+ (SubjectiveColor *)querySubjectiveColor:(NSString *)colorName context:(NSManagedObjectContext *)context;
+ (SubjectiveColor *)querySubjectiveColorByOrder:(NSNumber *)order context:(NSManagedObjectContext *)context;
+ (PaintSwatches *)queryPaintSwatches:(NSString *)swatchName context:(NSManagedObjectContext *)context;
+ (Keyword *)queryKeyword:(NSString *)keyword context:(NSManagedObjectContext *)context;
+ (SwatchKeyword *)querySwatchKeyword:(NSManagedObjectID *)keyword_id swatchId:(NSManagedObjectID *)swatch_id context:(NSManagedObjectContext *)context;
+ (NSMutableArray *)querySwatchKeywords:(NSManagedObjectID *)swatch_id context:(NSManagedObjectContext *)context;
+ (MixAssociation *)queryMixAssociation:(int)mix_assoc_id context:(NSManagedObjectContext *)context;
+ (NSMutableArray *)queryMixAssocBySwatch:(NSManagedObjectID *)swatch_id context:(NSManagedObjectContext *)context;

// Delete methods
//
+ (void)deleteSwatchKeywords:(PaintSwatches *)swatchObj context:(NSManagedObjectContext *)context;

@end
