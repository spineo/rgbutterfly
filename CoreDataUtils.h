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


// FETCH methods
//
+ (GlobalSettings *)fetchGlobalSettings;
+ (int)fetchIdCount:(NSString *)entityName idName:(NSString *)idName idValue:(int)idValue;
+ (NSMutableArray *)fetchMixAssociationsIds:(NSString *)idName idValue:(int)idValue returnName:(NSString *)returnName;
+ (NSMutableArray *)fetchMixAssocIds:(int)swatchId descId:(int)descId;
+ (NSMutableArray *)fetchAllMixAssocIds;
+ (NSMutableDictionary *)fetchMixAssoc:(int)swatchId descId:(int)descId;
+ (NSString *)fetchMixAssocName:(int)descId;
+ (NSMutableDictionary *)fetchAllSwatchKeywords;
+ (NSMutableDictionary *)fetchAllSubjColors;
+ (NSMutableDictionary *)fetchAllSwatchNames;


// INSERT methods
//
+ (void)initGlobalSettings;


// UPDATE methods
//
+ (void)updateGlobalSettings:(GlobalSettings *)obj;


// New method
//
+ (NSFetchedResultsController *)fetchedResultsController:(NSManagedObjectContext *)context entity:(NSString *)entity sortDescriptor:(NSString *)sortDescriptor predicate:(NSString *)predicate;

@end
