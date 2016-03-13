//
//  ManagedObjectUtils.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 1/23/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//
#import "AppDelegate.h"
#import "ManagedObjectUtils.h"

#import "GlobalSettings.h"
#import "GenericUtils.h"


@implementation ManagedObjectUtils

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Init methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Init Methods

// Call this method from GlobalSettings
//
+ (void)insertSubjectiveColors {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *subjColorEntity = [NSEntityDescription entityForName:@"SubjectiveColor" inManagedObjectContext:context];
    
    // Read the data text files
    //
    NSString* fileRoot = [[NSBundle mainBundle] pathForResource:@"SubjectiveColor"
                                                         ofType:@"txt"];
    // Get rid of new line
    //
    NSString* fileContents =
    [NSString stringWithContentsOfFile:fileRoot
                              encoding:NSUTF8StringEncoding error:nil];
    
    // First, separate by new line
    //
    NSArray* allLines =
    [fileContents componentsSeparatedByCharactersInSet:
     [NSCharacterSet newlineCharacterSet]];
    
    // Order is used for the color wheel (starting at zero)
    //
    int order = 0;
    for (NSString *line in allLines) {
        // Strip newlines and split by delimiters
        //
        NSString *colorCompsString = [line stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSMutableArray *colorComps = [GenericUtils trimStrings:[colorCompsString componentsSeparatedByString:@","]];
        
        if ([colorComps count] == 2) {
            NSString *colorName = [colorComps objectAtIndex:0];
            NSString *hexValue  = [colorComps objectAtIndex:1];
        
            SubjectiveColor *subjColor = [[SubjectiveColor alloc] initWithEntity:subjColorEntity insertIntoManagedObjectContext:context];
            [subjColor setName:colorName];
            [subjColor setHex_value:hexValue];
            [subjColor setOrder:[NSNumber numberWithInt:order]];
            
            order++;
        }
    }
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    } else {
        NSLog(@"Save successful");
    }
}

// Call this method from GlobalSettings
//
+ (void)insertPaintSwatchTypes {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *swatchTypeEntity = [NSEntityDescription entityForName:@"PaintSwatchType" inManagedObjectContext:context];
    
    // Read the data text files
    //
    NSString* fileRoot = [[NSBundle mainBundle] pathForResource:@"PaintSwatchType"
                                                         ofType:@"txt"];
    // Get rid of new line
    //
    NSString* fileContents =
    [NSString stringWithContentsOfFile:fileRoot
                              encoding:NSUTF8StringEncoding error:nil];
    
    // First, separate by new line
    //
    NSArray* allLines =
    [fileContents componentsSeparatedByCharactersInSet:
     [NSCharacterSet newlineCharacterSet]];
    
    // Order is used for the color wheel (starting at zero)
    //
    int order = 0;
    for (NSString *line in allLines) {
        // Strip newlines and split by delimiters
        //
        NSString *typeCompsString = [line stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSMutableArray *typeComps = [GenericUtils trimStrings:[typeCompsString componentsSeparatedByString:@","]];
        
        if ([typeComps count] == 1) {
            NSString *typeName = [typeComps objectAtIndex:0];
            
            PaintSwatchType *swatchType = [[PaintSwatchType alloc] initWithEntity:swatchTypeEntity insertIntoManagedObjectContext:context];
            [swatchType setName:typeName];
            [swatchType setOrder:[NSNumber numberWithInt:order]];
            
            order++;
        }
    }
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    } else {
        NSLog(@"Save successful");
    }
}

+ (void)insertPaintSwatches:(NSManagedObjectContext *)context {

    NSEntityDescription *paintSwatchEntity = [NSEntityDescription entityForName:@"PaintSwatch" inManagedObjectContext:context];

    // PaintSwatch 1
    //
    PaintSwatches *paintSwatch = [[PaintSwatches alloc] initWithEntity:paintSwatchEntity insertIntoManagedObjectContext:context];
    [paintSwatch setDeg_hue:[NSNumber numberWithInt:260]];
    [paintSwatch setIs_mix:[NSNumber numberWithInt:1]];
    [paintSwatch setSubj_color_id:[NSNumber numberWithInt:0]];
    [paintSwatch setType_id:[NSNumber numberWithInt:2]];
    [paintSwatch setCreate_date:[NSDate dateWithTimeIntervalSinceReferenceDate:459695337.438424]];
    [paintSwatch setCreate_date:[NSDate dateWithTimeIntervalSinceReferenceDate:459697449.493243]];
    [paintSwatch setAbbr_name:@"Purple + White"];
    [paintSwatch setBlue:@"160.00"];
    [paintSwatch setBrightness:@"0.6275"];
    [paintSwatch setDesc:@"This is a color mix with purple and white"];
    [paintSwatch setGreen:@"102.00"];
    [paintSwatch setHue:@"0.7241"];
    [paintSwatch setImage_url:@""];
    [paintSwatch setName:@"Purple + White 3:4"];
    [paintSwatch setRed:@"122.00"];
    [paintSwatch setSaturation:@"0.3625"];
    id image_thumb_1 = @"bplist00?X$versionX$objectsY$archiverT$top";
    [paintSwatch setImage_thumb:image_thumb_1];
    
    
    // PaintSwatch 2
    //
    PaintSwatches *paintSwatch2 = [[PaintSwatches alloc] initWithEntity:paintSwatchEntity insertIntoManagedObjectContext:context];
    [paintSwatch2 setDeg_hue:[NSNumber numberWithInt:28]];
    [paintSwatch2 setIs_mix:[NSNumber numberWithInt:1]];
    [paintSwatch2 setSubj_color_id:[NSNumber numberWithInt:0]];
    [paintSwatch2 setType_id:[NSNumber numberWithInt:2]];
    [paintSwatch2 setCreate_date:[NSDate dateWithTimeIntervalSinceReferenceDate:460240092.658472]];
    [paintSwatch2 setCreate_date:[NSDate dateWithTimeIntervalSinceReferenceDate:460240092.658475]];
    [paintSwatch2 setAbbr_name:@"Light Brown + White"];
    [paintSwatch2 setBlue:@"87.00"];
    [paintSwatch2 setBrightness:@"0.6392"];
    [paintSwatch2 setDesc:@"This is a color mix with light brown and white"];
    [paintSwatch2 setGreen:@"123.00"];
    [paintSwatch2 setHue:@"0.0789"];
    [paintSwatch2 setImage_url:@""];
    [paintSwatch2 setName:@"Light brown + White 0:1"];
    [paintSwatch2 setRed:@"163.00"];
    [paintSwatch2 setSaturation:@"0.4663"];
    id image_thumb_2 = @"bplist00?X$versionX$objectsY$archiverT$top";
    [paintSwatch2 setImage_thumb:image_thumb_2];
    
    NSEntityDescription *keywordEntity       = [NSEntityDescription entityForName:@"Keyword"         inManagedObjectContext:context];
    NSEntityDescription *swatchKeywordEntity = [NSEntityDescription entityForName:@"SwatchKeyword"   inManagedObjectContext:context];
    
    // Add Subjective Color Associations
    //
    SubjectiveColor *sc1 = [ManagedObjectUtils querySubjectiveColor:@"Violet" context:context];
    [paintSwatch setSubjective_color:sc1];
    [sc1 addPaint_swatchObject:paintSwatch];
    
    SubjectiveColor *sc2 = [ManagedObjectUtils querySubjectiveColor:@"Brown" context:context];
    [paintSwatch2 setSubjective_color:sc2];
    [sc2 addPaint_swatchObject:paintSwatch2];
    
    
    // Keywords
    //
    SwatchKeyword *skw = [[SwatchKeyword alloc] initWithEntity:swatchKeywordEntity insertIntoManagedObjectContext:context];
    Keyword *kw = [[Keyword alloc] initWithEntity:keywordEntity insertIntoManagedObjectContext:context];
    [kw setName:@"Earth"];
    [kw addSwatch_keywordObject:skw];
    [paintSwatch2 addSwatch_keywordObject:skw];
    
    SwatchKeyword *skw2 = [[SwatchKeyword alloc] initWithEntity:swatchKeywordEntity insertIntoManagedObjectContext:context];
    Keyword *kw2 = [[Keyword alloc] initWithEntity:keywordEntity insertIntoManagedObjectContext:context];
    [kw2 setName:@"Mud"];
    [kw2 addSwatch_keywordObject:skw2];
    [paintSwatch2 addSwatch_keywordObject:skw2];
    
    SwatchKeyword *skw2_2 = [[SwatchKeyword alloc] initWithEntity:swatchKeywordEntity insertIntoManagedObjectContext:context];
    Keyword *kw2_2 = [[Keyword alloc] initWithEntity:keywordEntity insertIntoManagedObjectContext:context];
    [kw2_2 setName:@"Silt"];
    [kw2_2 addSwatch_keywordObject:skw2_2];
    [paintSwatch2 addSwatch_keywordObject:skw2_2];
    
    SwatchKeyword *skw2_3 = [[SwatchKeyword alloc] initWithEntity:swatchKeywordEntity insertIntoManagedObjectContext:context];
    Keyword *kw2_3 = [[Keyword alloc] initWithEntity:keywordEntity insertIntoManagedObjectContext:context];
    [kw2_3 setName:@"Soil"];
    [kw2_3 addSwatch_keywordObject:skw2_3];
    [paintSwatch2 addSwatch_keywordObject:skw2_3];
    
    Keyword *kw3 = [[Keyword alloc] initWithEntity:keywordEntity insertIntoManagedObjectContext:context];
    SwatchKeyword *skw3 = [[SwatchKeyword alloc] initWithEntity:swatchKeywordEntity insertIntoManagedObjectContext:context];
    [kw3 setName:@"Overlapping"];
    [kw3 addSwatch_keywordObject:skw3];
    [paintSwatch2 addSwatch_keywordObject:skw3];
    
    SwatchKeyword *skw3b = [[SwatchKeyword alloc] initWithEntity:swatchKeywordEntity insertIntoManagedObjectContext:context];
    [kw3 addSwatch_keywordObject:skw3b];
    [paintSwatch addSwatch_keywordObject:skw3b];

    SwatchKeyword *skw4 = [[SwatchKeyword alloc] initWithEntity:swatchKeywordEntity insertIntoManagedObjectContext:context];
    Keyword *kw4 = [[Keyword alloc] initWithEntity:keywordEntity insertIntoManagedObjectContext:context];
    [kw4 setName:@"Hibiscus"];
    [kw4 addSwatch_keywordObject:skw4];
    [paintSwatch addSwatch_keywordObject:skw4];

    SwatchKeyword *skw5 = [[SwatchKeyword alloc] initWithEntity:swatchKeywordEntity insertIntoManagedObjectContext:context];
    Keyword *kw5 = [[Keyword alloc] initWithEntity:keywordEntity insertIntoManagedObjectContext:context];
    [kw5 setName:@"Ravens"];
    [kw5 addSwatch_keywordObject:skw5];
    [paintSwatch addSwatch_keywordObject:skw5];

    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    } else {
        NSLog(@"Save successful");
    }
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Fetch methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Fetch methods

// Generic fetch
//
+ (NSArray *)fetchEntity:(NSString *)entityName context:(NSManagedObjectContext *)context {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return results;
    } else {
        return nil;
    }
}

+ (NSArray *)fetchKeywords:(NSManagedObjectContext *)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SwatchKeyword" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:@"paint_swatch", @"keyword", nil]];
    
    [fetch setResultType: NSDictionaryResultType];

    NSError *error = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    if ([results count] > 0) {
        return results;
    } else {
        return nil;
    }
}

+ (NSMutableArray *)fetchPaintSwatches:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PaintSwatch" inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    
    // Skip match assoc types
    //
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"type_id != 3"]];

    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return (NSMutableArray *)results;
    } else {
        return nil;
    }
}

+ (NSMutableArray *)fetchMixAssociations:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MixAssociation" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return (NSMutableArray *)results;
    } else {
        return nil;
    }
}

+ (NSMutableArray *)fetchMatchAssociations:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MatchAssociation" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return (NSMutableArray *)results;
    } else {
        return nil;
    }
}

+ (NSMutableDictionary *)fetchSubjectiveColors:(NSManagedObjectContext *)context {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SubjectiveColor" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    NSMutableDictionary *subj_colors = [[NSMutableDictionary alloc] init];
    
    for (SubjectiveColor *subjColorObj in results) {
     
        NSString *name            = [subjColorObj name];
        NSString *hex_value       = [subjColorObj hex_value];
        NSString *order           = [[subjColorObj order] stringValue];
        
        NSDictionary *colorsProps = @{
                                      @"hex" : hex_value,
                                      @"id"  : order,
                                    };
        
        [subj_colors setObject:colorsProps forKey:name];
    }
    
    return subj_colors;
}

// Generic method to fetch ordered names (SubjectiveColor and PaintSwatchTypes)
//
+ (NSMutableArray *)fetchDictNames:(NSString *)entityName context:(NSManagedObjectContext *)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:@"name", nil]];
    
    [fetch setResultType: NSDictionaryResultType];
    
    NSSortDescriptor *orderSort = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    [fetch setSortDescriptors:@[ orderSort ]];
    
    NSError *error = nil;
    NSArray *arrayOfDict    = [context executeFetchRequest:fetch error:&error];
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in arrayOfDict) {
        NSString *name = [dict valueForKey:@"name"];
        
        [results addObject:name];
    }
    
    if ([results count] > 0) {
        return results;
    } else {
        return nil;
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Query methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Query methods

+ (NSMutableArray *)queryMixAssocSwatches:(NSManagedObjectID *)mix_assoc_id context:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MixAssocSwatch" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"mix_association == %@", mix_assoc_id]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return (NSMutableArray *)results;
    } else {
        return nil;
    }
}

+ (NSMutableArray *)queryTapAreas:(NSManagedObjectID *)match_assoc_id context:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TapArea" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"match_association == %@", match_assoc_id]];
    
    NSSortDescriptor *orderSort = [[NSSortDescriptor alloc] initWithKey:@"tap_order" ascending:YES];
    [fetchRequest setSortDescriptors:@[ orderSort ]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return (NSMutableArray *)results;
    } else {
        return nil;
    }
}

+ (SubjectiveColor *)querySubjectiveColor:(NSString *)colorName context:(NSManagedObjectContext *)context {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SubjectiveColor" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    [fetch setPredicate: [NSPredicate predicateWithFormat:@"name == %@", colorName]];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    if ([results count] == 0) {
        return nil;
    } else {
        return [results objectAtIndex:0];
    }
}

+ (SubjectiveColor *)querySubjectiveColorByOrder:(NSNumber *)order context:(NSManagedObjectContext *)context {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SubjectiveColor" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    [fetch setPredicate: [NSPredicate predicateWithFormat:@"order == %@", order]];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    if ([results count] == 0) {
        return nil;
    } else {
        return [results objectAtIndex:0];
    }
}

+ (PaintSwatches *)queryPaintSwatches:(NSString *)swatchName context:(NSManagedObjectContext *)context {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PaintSwatch" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    [fetch setPredicate: [NSPredicate predicateWithFormat:@"name == %@", swatchName]];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    if ([results count] == 0) {
        return nil;
    } else {
        return [results objectAtIndex:0];
    }
}

+ (Keyword *)queryKeyword:(NSString *)keyword context:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Keyword" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"name == [c] %@", keyword]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return [results objectAtIndex:0];
    } else {
        return nil;
    }
}

+ (SwatchKeyword *)querySwatchKeyword:(NSManagedObjectID *)keyword_id swatchId:(NSManagedObjectID *)swatch_id context:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SwatchKeyword" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"keyword == %@ and paint_swatch == %@", keyword_id, swatch_id]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return [results objectAtIndex:0];
    } else {
        return nil;
    }
}

+ (NSArray *)querySwatchKeywords:(NSManagedObjectID *)swatch_id context:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SwatchKeyword" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"paint_swatch == %@", swatch_id]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return results;
    } else {
        return nil;
    }
}

+ (MixAssociation *)queryMixAssociation:(int)mix_assoc_id context:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MixAssociation" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"objectID == %i", mix_assoc_id]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return [results objectAtIndex:0];
    } else {
        return nil;
    }
}


+ (NSMutableArray *)queryMixAssocBySwatch:(NSManagedObjectID *)swatch_id context:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MixAssocSwatch" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"paint_swatch == %@", swatch_id]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return (NSMutableArray *)results;
    } else {
        return nil;
    }
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Delete methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Delete methods

+ (void)deleteSwatchKeywords:(PaintSwatches *)swatchObj context:(NSManagedObjectContext *)context {

    NSArray *swatchKeywords = [self querySwatchKeywords:swatchObj.objectID context:context];

    for (SwatchKeyword *swatchKeywordObj in swatchKeywords) {
        if (swatchKeywordObj != nil) {

            Keyword *keywordObj = swatchKeywordObj.keyword;
            [keywordObj removeSwatch_keywordObject:swatchKeywordObj];
            [swatchObj removeSwatch_keywordObject:swatchKeywordObj];
            
            [context deleteObject:swatchKeywordObj];
        }
    }
}

@end
