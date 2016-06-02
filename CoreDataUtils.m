//
//  CoreDataUtils.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 5/24/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "CoreDataUtils.h"
#import "AppDelegate.h"
#import "ACPMixAssociationsDesc.h"

@implementation CoreDataUtils


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// FETCH methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Fetch Methods

// Check if TapAreaSize is already defined in the GlobalSettings entity
//
+ (GlobalSettings *)fetchGlobalSettings {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *global_settings = [NSEntityDescription entityForName:@"GlobalSetting" inManagedObjectContext:context];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:global_settings];
    
    fetch.resultType = NSDictionaryResultType;
    
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:@"tap_area_size", @"tap_area_shape", nil]];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    GlobalSettings *globalSettings = [[GlobalSettings alloc] init];
    globalSettings.tap_area_size  = 0;
    globalSettings.tap_area_shape = nil;
    
    if ([results count] > 0) {
        globalSettings.tap_area_size  = [[results[0] objectForKey:@"tap_area_size"] intValue];
        globalSettings.tap_area_shape = (NSString *)[results[0] objectForKey:@"tap_area_shape"];
    }
    
    return globalSettings;
}

+ (NSMutableArray *)fetchSwatchKeywords:(int)swatchId {

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SwatchKeywords" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    fetch.predicate = [NSPredicate predicateWithFormat:@"swatch_id == %i", swatchId];
    
    fetch.resultType = NSDictionaryResultType;
    
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:@"keyword_id", nil]];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    NSMutableArray *keywordNames = [[NSMutableArray alloc] init];
    for (int i=0; i<[results count]; i++) {
        int keyword_id = [[results[i] objectForKey:@"keyword_id"] intValue];
        
        NSString *keyword_name = [[NSString alloc] initWithString:[self fetchKeywordName:keyword_id]];

        [keywordNames addObject:keyword_name];
    }
    
    return keywordNames;
}

+ (NSString *)fetchKeywordName:(int)keywordId {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"KeywordName" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    fetch.predicate = [NSPredicate predicateWithFormat:@"uid == %i", keywordId];
    
    fetch.resultType = NSDictionaryResultType;
    
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:@"name", nil]];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    if ([results count] > 0) {
        return [results[0] objectForKey:@"name" ];
    } else {
        return @"";
    }
}

+ (int)fetchUIDCount:(NSString *)entityName uidValue:(int)uid {

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];

    [fetch setEntity:entity];
    
    fetch.predicate = [NSPredicate predicateWithFormat:@"uid == %i", uid];

    fetch.resultType = NSDictionaryResultType;

    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:@"uid", nil]];

    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    return (int)[results count];
}

+ (int)fetchIdCount:(NSString *)entityName idName:(NSString *)idName idValue:(int)idValue {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    fetch.predicate = [NSPredicate predicateWithFormat:@"%K == %i", idName, idValue];
    
    fetch.resultType = NSDictionaryResultType;
    
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:idName, nil]];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    return (int)[results count];
}

+ (int)fetchUID:(NSString *)entityName attrName:(NSString *)attrName attrValue:(NSString *)attrValue {

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    fetch.predicate = [NSPredicate predicateWithFormat:@"%K == %@", attrName, attrValue];
    
    fetch.resultType = NSDictionaryResultType;
    
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:@"uid", nil]];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    if ([results count] > 0) {
        return [[results[0] objectForKey:@"uid" ] intValue];
    } else {
        return 0;
    }
}

+ (int)fetchSwatchKeywordsCount:(int)swatchId keywordId:(int)keywordId {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SwatchKeywords" inManagedObjectContext:context];

    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];

    [fetch setEntity:entity];

    fetch.predicate = [NSPredicate predicateWithFormat:@"swatch_id == %i AND keyword_id == %i", swatchId, keywordId];

    fetch.resultType = NSDictionaryResultType;

    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:@"swatch_id", nil]];

    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];

    return (int)[results count];
}

+ (NSMutableArray *)fetchMixAssociationsIds:(NSString *)idName idValue:(int)idValue returnName:(NSString *)returnName {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MixAssociation" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    [fetch setReturnsDistinctResults:YES];
    
    fetch.predicate = [NSPredicate predicateWithFormat:@"%K == %i", idName, idValue];
    
    fetch.resultType = NSDictionaryResultType; 
    
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:returnName, nil]];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    NSMutableArray *returnIds = [[NSMutableArray alloc] init];
    for (int i=0; i<[results count]; i++) {
        int return_id = [[results[i] objectForKey:returnName] intValue];
        
        [returnIds addObject:[NSNumber numberWithInt:return_id]];
    }
    
    return returnIds;
}


// This takes into account the 'Add Mix'
//
+ (NSMutableArray *)fetchMixAssocIds:(int)swatchId descId:(int)descId {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MixAssociation" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    fetch.predicate = [NSPredicate predicateWithFormat:@"swatch_id == %i AND desc_id == %i", swatchId, descId];
    
    fetch.resultType = NSDictionaryResultType;
    
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:@"swatch_id", nil]];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    NSMutableArray *returnIds = [[NSMutableArray alloc] init];
    for (int i=0; i<[results count]; i++) {
        int return_id = [[results[i] objectForKey:@"swatch_id"] intValue];
        
        [returnIds addObject:[NSNumber numberWithInt:return_id]];
    }
    
    return returnIds;
}

+ (NSMutableArray *)fetchAllMixAssocIds {

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MixAssociation" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    fetch.resultType = NSDictionaryResultType;
    
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:@"desc_id", nil]];
    [fetch setReturnsDistinctResults:YES];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    NSMutableArray *returnIds = [[NSMutableArray alloc] init];
    for (int i=0; i<[results count]; i++) {
        int return_id = [[results[i] objectForKey:@"desc_id"] intValue];
        
        [returnIds addObject:[NSNumber numberWithInt:return_id]];
    }
    
    return returnIds;
}

+ (NSMutableDictionary *)fetchMixAssoc:(int)swatchId descId:(int)descId {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MixAssociation" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    fetch.predicate = [NSPredicate predicateWithFormat:@"swatch_id == %i AND desc_id == %i", swatchId, descId];
    
    fetch.resultType = NSDictionaryResultType;
    
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:@"uid", @"dom_parts_ratio", @"mix_order", @"mix_parts_ratio", nil]];

    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    NSMutableDictionary *returnValues = [[NSMutableDictionary alloc] init];
    for (int i=0; i<[results count]; i++) {
        [returnValues setObject:[results[i] objectForKey:@"uid"] forKey:@"uid"];
        [returnValues setObject:[results[i] objectForKey:@"dom_parts_ratio"] forKey:@"dom_parts_ratio"];
        [returnValues setObject:[results[i] objectForKey:@"dom_parts_ratio"] forKey:@"mix_order"];
        [returnValues setObject:[results[i] objectForKey:@"mix_parts_ratio"] forKey:@"mix_parts_ratio"];
    }
    
    return returnValues;
}

+ (ACPMixAssociationsDesc *)fetchMixAssocDesc:(int)descId {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MixAssociationDesc" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    fetch.predicate = [NSPredicate predicateWithFormat:@"uid == %i", descId];
    
    fetch.resultType = NSDictionaryResultType;
    
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:@"uid", @"mix_assoc_name", @"mix_assoc_desc", nil]];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    ACPMixAssociationsDesc *mixAssocDesc = [[ACPMixAssociationsDesc alloc] init];
    

    mixAssocDesc.uid  = [[results[0] objectForKey:@"uid"] intValue];
    mixAssocDesc.mix_assoc_name = [results[0] objectForKey:@"mix_assoc_name"];
    mixAssocDesc.mix_assoc_desc = [results[0] objectForKey:@"mix_assoc_desc"];
    
    return mixAssocDesc;
}

+ (NSString *)fetchMixAssocName:(int)descId {

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MixAssociationDesc" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    fetch.predicate = [NSPredicate predicateWithFormat:@"uid == %i", descId];
    
    fetch.resultType = NSDictionaryResultType;
    
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:@"mix_assoc_name", nil]];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    NSString *mixAssocName = [[NSString alloc] init];
    for (int i=0; i<[results count]; i++) {
        mixAssocName = [results[i] objectForKey:@"mix_assoc_name"];
    }
    
    return mixAssocName;
}

+ (NSMutableDictionary *)fetchAllSwatchKeywords {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SwatchKeywords" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    fetch.resultType = NSDictionaryResultType;
    
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:@"keyword_id", @"swatch_id", nil]];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    NSMutableDictionary *keywordNames = [[NSMutableDictionary alloc] init];
    for (int i=0; i<[results count]; i++) {
        int keyword_id = [[results[i] objectForKey:@"keyword_id"] intValue];
        int swatch_id  = [[results[i] objectForKey:@"swatch_id"] intValue];
        
        NSString *keyword_name = [[NSString alloc] initWithString:[self fetchKeywordName:keyword_id]];
        
        if (![keyword_name isEqualToString:@""]) {
            id swatchIds = [keywordNames objectForKey:keyword_name];
            if ( nil == swatchIds ) {
                swatchIds = [NSMutableArray array];
                [keywordNames setObject:swatchIds forKey:keyword_name];
            }
            [swatchIds addObject:[NSNumber numberWithInt:swatch_id]];
        }
    }
    
    return keywordNames;
}

+ (NSMutableDictionary *)fetchAllSubjColors {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PaintSwatch" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    fetch.resultType = NSDictionaryResultType;
    
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:@"pk", @"subj_color_id", nil]];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    NSMutableDictionary *subjColorNames = [[NSMutableDictionary alloc] init];
    for (int i=0; i<[results count]; i++) {
        int swatch_id  = [[results[i] objectForKey:@"pk"] intValue];
        int subj_color_id = [[results[i] objectForKey:@"subj_color_id"] intValue];
        
        NSString *subj_color_name = [[NSString alloc] initWithString:[GlobalSettings getColorName:subj_color_id]];
        
        if (![subj_color_name isEqualToString:@"Other"]) {
            id swatchIds = [subjColorNames objectForKey:subj_color_name];
            if ( nil == swatchIds ) {
                swatchIds = [NSMutableArray array];
                [subjColorNames setObject:swatchIds forKey:subj_color_name];
            }
            [swatchIds addObject:[NSNumber numberWithInt:swatch_id]];
        }
    }
    
    return subjColorNames;
}

+ (NSMutableDictionary *)fetchAllSwatchNames {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PaintSwatch" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    fetch.resultType = NSDictionaryResultType;
    
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:@"pk", @"name", nil]];
    
    // Fetch only reference types
    //
    fetch.predicate = [NSPredicate predicateWithFormat:@"type_id == 1"];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    NSMutableDictionary *swatchNames = [[NSMutableDictionary alloc] init];
    for (int i=0; i<[results count]; i++) {
        int swatch_id  = [[results[i] objectForKey:@"pk"] intValue];
        NSString *swatch_name = [results[i] objectForKey:@"name"];

        [swatchNames setObject:@[ [NSNumber numberWithInt:swatch_id] ] forKey:swatch_name];
    }
    
    return swatchNames;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// INSERT methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Insert Methods

+ (void)initGlobalSettings {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSManagedObject *insert = [NSEntityDescription insertNewObjectForEntityForName:@"GlobalSetting" inManagedObjectContext:context];
    
    [insert setValue:[NSNumber numberWithInteger:1]  forKey:@"backup_schedule"];
    [insert setValue:[NSNumber numberWithInteger:11] forKey:@"backup_time"];
    [insert setValue:[NSNumber numberWithBool:1]     forKey:@"can_add_swatch_types"];
    [insert setValue:[NSNumber numberWithBool:1]     forKey:@"icloud_sync"];
    [insert setValue:[NSNumber numberWithBool:1]     forKey:@"is_ref_data_editable"];
    [insert setValue:[NSNumber numberWithInteger:10] forKey:@"num_matches_to_show"];
    [insert setValue:[NSNumber numberWithInteger:40] forKey:@"tap_area_size"];
    [insert setValue:@"Circle"                       forKey:@"tap_area_shape"];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

+ (void)insertSwatchKeywords:(int)swatchId keywordId:(int)keywordId {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSManagedObject *insert = [NSEntityDescription insertNewObjectForEntityForName:@"SwatchKeywords" inManagedObjectContext:context];
    
    [insert setValue:[NSNumber numberWithInt:swatchId]  forKey:@"swatch_id"];
    [insert setValue:[NSNumber numberWithInt:keywordId] forKey:@"keyword_id"];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// UPDATE methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Update Methods

+ (void)updateGlobalSettings:(GlobalSettings *)obj {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *global_settings = [NSEntityDescription entityForName:@"GlobalSetting" inManagedObjectContext:context];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:global_settings];
    
    NSArray *results = [context executeFetchRequest:fetch error:NULL];
    
    if ([results count] > 0) {
        [results[0] setValue:[NSNumber numberWithInteger:obj.tap_area_size] forKey:@"tap_area_size"];
        [results[0] setValue:obj.tap_area_shape                             forKey:@"tap_area_shape"];
    }
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    } else {
        NSLog(@"Sucessful save Global Settings");
    }
}

+ (void)updateMixDesc:(ACPMixAssociationsDesc *)obj {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MixAssociationDesc" inManagedObjectContext:context];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    //fetch.predicate = [NSPredicate predicateWithFormat:@"uid == %d", (int)uid];
    fetch.predicate = [NSPredicate predicateWithFormat:@"uid == %@", [[NSString alloc] initWithFormat:@"%i", obj.uid]];
    
    NSArray *results = [context executeFetchRequest:fetch error:NULL];
    
    if ([results count] == 1) {
        [results[0] setValue:obj.mix_assoc_name forKey:@"mix_assoc_name"];
        [results[0] setValue:obj.mix_assoc_desc forKey:@"mix_assoc_desc"];
    }
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// DELETE methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Delete Methods

+ (void)deleteObj:(NSString *)entityName uidValue:(int)uid context:context {

    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    fetch.predicate = [NSPredicate predicateWithFormat:@"uid == %i", uid];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:fetch error:&error];
    
    if ([results count] == 1) {
        [context deleteObject:results[0]];
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// New methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Query
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

+ (NSFetchedResultsController *)fetchedResultsController:(NSManagedObjectContext *)context entity:(NSString *)entity sortDescriptor:(NSString *)sortDescriptor predicate:(NSString *)predicate {
    
    NSFetchRequest *fetchRequest  = [[NSFetchRequest alloc] initWithEntityName: entity];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:sortDescriptor ascending:YES]]];
    
    if (![predicate isEqualToString:@""]) {
        [fetchRequest setPredicate: [NSPredicate predicateWithFormat: predicate]];
    }

    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];

    NSError *error = nil;
    [fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    
    return fetchedResultsController;
}

@end
