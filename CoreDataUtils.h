//
//  CoreDataUtils.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 5/24/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "GlobalSettings.h"
#import "PaintSwatches.h"
//#import "ACPMixAssociationDesc.h"


@interface CoreDataUtils : NSObject

// UID methods
//
+ (int)getUID;


// FETCH methods
//
+ (GlobalSettings *)fetchGlobalSettings;
+ (int)fetchCount:(NSString *)entityName;
+ (int)fetchIdCount:(NSString *)entityName idName:(NSString *)idName idValue:(int)idValue;
+ (NSMutableArray *)fetchMixAssociationsIds:(NSString *)idName idValue:(int)idValue returnName:(NSString *)returnName;
+ (NSMutableArray *)fetchMixAssocIds:(int)swatchId descId:(int)descId;
+ (NSMutableArray *)fetchAllMixAssocIds;
+ (NSMutableDictionary *)fetchMixAssoc:(int)swatchId descId:(int)descId;
//+ (ACPMixAssociationsDesc *)fetchMixAssocDesc:(int)descId;
+ (NSString *)fetchMixAssocName:(int)descId;
+ (NSMutableDictionary *)fetchAllSwatchKeywords;
+ (NSMutableDictionary *)fetchAllSubjColors;
+ (NSMutableDictionary *)fetchAllSwatchNames;


// INSERT methods
//
+ (void)initGlobalSettings;
//+ (ACPMixAssociationDesc *)insertMixDesc:(ACPMixAssociationDesc *)obj;
//+ (PaintSwatches *)insertPaintSwatch:(PaintSwatches *)obj;
//+ (void)addMixAssociation:(PaintSwatches *)obj;


// UPDATE methods
//
+ (void)updateGlobalSettings:(GlobalSettings *)obj;
//+ (void)updateMixDesc:(ACPMixAssociationDesc *)obj;
//+ (void)updatePaintSwatch:(PaintSwatches *)obj;


// DELETE methods
//
//+ (int)deletePaintSwatch:(PaintSwatches *)obj;

// New method
//
+ (NSFetchedResultsController *)fetchedResultsController:(NSManagedObjectContext *)context entity:(NSString *)entity sortDescriptor:(NSString *)sortDescriptor predicate:(NSString *)predicate;

@end
