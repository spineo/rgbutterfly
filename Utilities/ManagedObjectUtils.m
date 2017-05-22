//
//  ManagedObjectUtils.m
//  RGButterfly
//
//  Created by Stuart Pineo on 1/23/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//
#import "AppDelegate.h"
#import "ManagedObjectUtils.h"
#import "AssociationType+CoreDataProperties.h"
#import "PaintSwatchType.h"
#import "CanvasCoverage+CoreDataProperties.h"

#import "GlobalSettings.h"
#import "GenericUtils.h"
#import "AppColorUtils.h"


@implementation ManagedObjectUtils

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Init methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Init Methods

// Call this method from GlobalSettings
//
+ (void)insertSubjectiveColors {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
        NSLog(@"Error inserting context: %@\n%@", [error localizedDescription], [error userInfo]);
    } else {
        NSLog(@"Insert successful");
    }
}

// Call this method from GlobalSettings: Generic insert method
//
+ (void)insertFromDataFile:(NSString *)entityName {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    // Read the data text files
    //
    NSString* fileRoot = [[NSBundle mainBundle] pathForResource:entityName
                                                         ofType:@"txt"];

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
        NSString *compsString = [line stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSMutableArray *comps = [GenericUtils trimStrings:[compsString componentsSeparatedByString:@","]];
        
        if ([comps count] == 1) {
            NSString *name = [comps objectAtIndex:0];
            
            if (! [name isEqualToString:@""]) {
                id managedObject = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
                [managedObject setName:name];
                [managedObject setOrder:[NSNumber numberWithInt:order]];
                
                order++;
            }
        }
    }
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Error inserting into '%@': %@\n%@", entityName, [error localizedDescription], [error userInfo]);
    } else {
        NSLog(@"Insert for '%@' successful", entityName);
    }
}

// Call this method from GlobalSettings: Bulk load Generic association if non-existent
//
+ (void)bulkLoadGenericAssociation:(NSString *)fileName {

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    // Create the Mix Association first
    //
    NSString *entityName = @"MixAssociation";
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    MixAssociation *mixAssoc = [[MixAssociation alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    
    // Composite Name
    //
    [mixAssoc setName:fileName];

    // Look up the AssocType id
    //
    AssociationType *assocType = [self queryDictionaryByNameValue:@"AssociationType" nameValue:@"Generic" context:context];
    [mixAssoc setAssoc_type_id:[assocType order]];
    

    // Look up the PaintSwatchType id
    //
    PaintSwatchType *paintSwatchType = [self queryDictionaryByNameValue:@"PaintSwatchType" nameValue:@"Generic" context:context];

    
    // Version tag
    //
    [mixAssoc setVersion_tag:[NSNumber numberWithInt:VERSION_TAG]];
    
    // Dates
    //
    NSDate *currDate = [NSDate date];
    [mixAssoc setCreate_date:currDate];
    [mixAssoc setLast_update:currDate];

    
    // Read the data text file and create the PaintSwatch
    //
    NSString* fileRoot = [[NSBundle mainBundle] pathForResource:fileName
                                                         ofType:@"txt"];
    
    NSString* fileContents =
    [NSString stringWithContentsOfFile:fileRoot
                              encoding:NSUTF8StringEncoding error:nil];
    
    // First, separate by new line
    //
    NSArray* allLines =
    [fileContents componentsSeparatedByCharactersInSet:
     [NSCharacterSet newlineCharacterSet]];
    
    NSString *PSEntityName = @"PaintSwatch";
    NSEntityDescription *PSEntity = [NSEntityDescription entityForName:PSEntityName inManagedObjectContext:context];
    
    NSString *assocSwatchEntityName = @"MixAssocSwatch";
    NSEntityDescription *assocSwatchEntity = [NSEntityDescription entityForName:assocSwatchEntityName inManagedObjectContext:context];
    
    int line_num  = 0;
    int mix_order = 1;
    
    CGFloat hue, sat, bri, alpha;
    
    for (NSString *line in allLines) {
        line_num++;
        if (line_num == 1)
            continue;
        
        // Strip newlines and split by tab delimiters
        //
        NSString *compsString = [line stringByReplacingOccurrencesOfString:@"\n" withString:@""];

        NSMutableArray *comps = [GenericUtils trimStrings:[compsString componentsSeparatedByString:@";"]];
        
        if ([comps count] == 4) {
            NSString *gen_name   = [[comps objectAtIndex:0] capitalizedString];
            NSString *rgb        = [comps objectAtIndex:1];
            NSString *hex        = [comps objectAtIndex:2];
            NSString *subj_color = [comps objectAtIndex:3];

            // Look up the Subjective Color id
            //
            SubjectiveColor *subjColor = [self queryDictionaryByNameValue:@"SubjectiveColor" nameValue:subj_color context:context];
            
            NSArray *rgbComps    = [GenericUtils trimStrings:[rgb componentsSeparatedByString:@"."]];
            
            if (! [gen_name isEqualToString:@""]) {
                PaintSwatches *paintSwatch = [[PaintSwatches alloc] initWithEntity:PSEntity insertIntoManagedObjectContext:context];
                
                NSString *disp_name = [[NSString alloc] initWithFormat:@"%@ (Generic)", gen_name];
                [paintSwatch setName:disp_name];
                
                // Version tag
                //
                [paintSwatch setVersion_tag:[NSNumber numberWithInt:VERSION_TAG]];
                
                // Dates
                //
                [paintSwatch setCreate_date:currDate];
                [paintSwatch setLast_update:currDate];
                
                // Convert RGB (Alpha should default to 1.0)
                //
                NSString *red   = [NSString stringWithFormat:@"%f", [[rgbComps objectAtIndex:0] floatValue]];
                NSString *green = [NSString stringWithFormat:@"%f", [[rgbComps objectAtIndex:1] floatValue]];
                NSString *blue  = [NSString stringWithFormat:@"%f", [[rgbComps objectAtIndex:2] floatValue]];
                NSString *alphaStr = @"1.0";
                
                [paintSwatch setRed:red];
                [paintSwatch setGreen:green];
                [paintSwatch setBlue:blue];
                [paintSwatch setAlpha:alphaStr];
                
                UIImage *image_thumb = [AppColorUtils renderRGBFromValues:red green:green blue:blue alpha:alphaStr cellWidth:DEF_TABLE_CELL_HEIGHT cellHeight:DEF_TABLE_CELL_HEIGHT];
                [paintSwatch setImage_thumb:[NSData dataWithData:UIImagePNGRepresentation(image_thumb)]];
                
                UIColor *rgbColor = [AppColorUtils colorFromSwatch:paintSwatch];
                
                [rgbColor getHue:&hue saturation:&sat brightness:&bri alpha:&alpha];
                
                [paintSwatch setHue:[NSString stringWithFormat:@"%f", hue]];
                [paintSwatch setSaturation:[NSString stringWithFormat:@"%f", sat]];
                [paintSwatch setBrightness:[NSString stringWithFormat:@"%f", bri]];
                [paintSwatch setAlpha:[NSString stringWithFormat:@"%f", alpha]];
                [paintSwatch setDeg_hue:[NSNumber numberWithFloat:hue * 360]];
                

                // Add Hex to the Comments
                //
                [paintSwatch setDesc:[[NSString alloc] initWithFormat:@"Hex Color Code: #%@", hex]];

                
                // Set the type_id
                //
                [paintSwatch setType_id:[paintSwatchType order]];

                
                // Set the subj_color_id
                //
                [paintSwatch setSubj_color_id:[subjColor order]];

                
                // MixAssocSwatch
                //
                MixAssocSwatch *mixAssocSwatch = [[MixAssocSwatch alloc] initWithEntity:assocSwatchEntity insertIntoManagedObjectContext:context];
                
                [mixAssocSwatch setMix_order:[NSNumber numberWithInt:mix_order]];
                
                // Version tag
                //
                [mixAssocSwatch setVersion_tag:[NSNumber numberWithInt:VERSION_TAG]];
                
                // Link it to the MixAssociation, MixAssocSwatch, and PaintSwatch
                //
                [mixAssocSwatch setMix_association:mixAssoc];
                [mixAssocSwatch setPaint_swatch:(PaintSwatch *)paintSwatch];
                
                [mixAssoc addMix_assoc_swatchObject:mixAssocSwatch];
                [paintSwatch addMix_assoc_swatchObject:mixAssocSwatch];
                
                mix_order++;
            }
        }
    }
    
    // Save only if anything was created
    //
    if (line_num > 0) {
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error inserting into MixAssocation, MixAssocSwatch, and associated PaintSwatches: %@\n%@", [error localizedDescription], [error userInfo]);
        } else {
            NSLog(@"Insert for MixAssociation, MixAssocSwatch, and associated PaintSwatches successful");
        }
    }
}


+ (void)insertTestPaintSwatches:(NSManagedObjectContext *)context {

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

// Update Versions
//
// Call this method from GlobalSettings: Generic insert method
//
+ (void)updateVersions {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    for (NSString *entityName in ENTITY_LIST) {
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        
        [fetch setEntity:entity];
        
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"version_tag == ''"]];
        
        NSArray *results = [context executeFetchRequest:fetch error:NULL];
        
        for (id entity in results) {
            [entity setVersion_tag:[NSNumber numberWithInt:VERSION_TAG]];
        }
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error updating context: %@\n%@", [error localizedDescription], [error userInfo]);
        } else {
            NSLog(@"Successfully updated %i rows for entity '%@'", (int)[results count], entityName);
        }
    }
    
}

+ (void)createEntityCSVFiles {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    for (NSString *entityName in ENTITY_LIST) {
        
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        
        [fetch setEntity:entityDesc];
        
        NSArray *results = [context executeFetchRequest:fetch error:NULL];
        
        NSString *filePath = [[NSString alloc] initWithFormat:@"%@/%@.txt", LOCAL_PATH, entityName];
        
        
        NSString *text = @"";
        NSError *error;
        [text writeToFile:filePath atomically:NO encoding:NSUTF8StringEncoding error:&error];

        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];

        for (id object in results) {
            NSArray *keys = [[[object entity] attributesByName] allKeys];
            NSDictionary *attributes = [object dictionaryWithValuesForKeys:keys];

            text = @"";
            for (NSString *attributeName in attributes) {
            
                id value = [object valueForKey:attributeName];

                NSString *strValue = @"";
                
                if ([value isKindOfClass:[NSNull class]] || value == nil) {
                    strValue = @"";

                } else if ([value isKindOfClass:[NSNumber class]]) {
                    if ([value intValue] == 0) {
                        strValue = @"";
                        
                    } else {
                        strValue = [value stringValue];
                    }

                } else if ([value isKindOfClass:[NSDate class]]) {
                    strValue = [dateFormatter stringFromDate:value];
                    
                } else if ([value isKindOfClass:[NSData class]]) {
                    strValue = [value base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                    
                } else if ([value isKindOfClass:[NSString class]]) {
                    strValue = value;
                }

                if (![text isEqualToString:@""]) {
                    text = @",";
                }
                text = [[NSString alloc] initWithFormat:@"%@\"%@\"", text, strValue];

                
                [fileHandle seekToEndOfFile];
                [fileHandle writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];

            }
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [fileHandle closeFile];
    }
    
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Fetch methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Fetch methods

// Generic fetch
//
+ (int)fetchCount:(NSString *)entityName {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    NSError *error      = nil;
    int count = (int)[context countForFetchRequest:fetch error:&error];
    
    return count;
}

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
    
    // Sort paint swatches
    //
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    // Skip match assoc types
    //
    // Filter out match association swatches
    //
    PaintSwatchType *paintSwatchType = [ManagedObjectUtils queryDictionaryByNameValue:@"PaintSwatchType" nameValue:@"MatchAssoc" context:context];
    int match_assoc_id = [[paintSwatchType order] intValue];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"type_id != %i", match_assoc_id]];
    
    [fetchRequest setSortDescriptors:@[nameSort]];

    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return (NSMutableArray *)results;
    } else {
        return nil;
    }
}

+ (NSMutableArray *)filterMatchPaintSwatches:(NSManagedObjectContext *)context userDefaults:(NSUserDefaults *)userDefaults {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PaintSwatch" inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    
    // Sort paint swatches
    //
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    // Skip match assoc types
    //
    // Filter out match association swatches
    //
    PaintSwatchType *matchSwatchType = [ManagedObjectUtils queryDictionaryByNameValue:@"PaintSwatchType" nameValue:@"MatchAssoc" context:context];
    int match_assoc_id = [[matchSwatchType order] intValue];
    
    CanvasCoverage *coverageType = [ManagedObjectUtils queryDictionaryByNameValue:@"CanvasCoverage" nameValue:@"Thick" context:context];
    int thick_cov_id = [[coverageType order] intValue];
    
    PaintSwatchType *genSwatchType = [ManagedObjectUtils queryDictionaryByNameValue:@"PaintSwatchType" nameValue:@"Generic" context:context];
    int generic_id = [[genSwatchType order] intValue];
    
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"type_id != %i", match_assoc_id]];
    [fetchRequest setSortDescriptors:@[nameSort]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray *filteredResults = [[NSMutableArray alloc] init];
    
    for (PaintSwatches *paintSwatch in results) {
        
        // Get the ids
        //
        int type_id = [[paintSwatch type_id] intValue];
        int coverage_id = [[paintSwatch coverage_id] intValue];

        // Generic filter
        //
        BOOL genFilter = [userDefaults boolForKey:GEN_FILTER_KEY];
        if (genFilter == TRUE && type_id == generic_id) {
            continue;
        }
        
        // Coverage filter
        //
        BOOL covFilter = [userDefaults boolForKey:COV_FILTER_KEY];
        if (covFilter == TRUE && coverage_id != thick_cov_id && type_id != generic_id) {
            continue;
        }

        [filteredResults addObject:paintSwatch];
    }
    
    if ([filteredResults count] > 0) {
        return filteredResults;
    } else {
        return nil;
    }
}

+ (NSMutableArray *)fetchMixAssociations:(NSManagedObjectContext *)context name:(NSString *)name {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MixAssociation" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    if (name != nil) {
        NSString *regexName = [[NSString alloc] initWithFormat:@"%@*", name];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name like[c] %@", regexName]];
    }
    
    NSSortDescriptor *nameSort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[ nameSort ]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return (NSMutableArray *)results;
    } else {
        return nil;
    }
}

+ (NSMutableArray *)fetchMatchAssociations:(NSManagedObjectContext *)context name:(NSString *)name {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MatchAssociation" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    if (name != nil) {
        NSString *regexName = [[NSString alloc] initWithFormat:@"%@*", name];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name like[c] %@", regexName]];
    }
    
    [fetchRequest setPropertiesToFetch:[[NSArray alloc] initWithObjects:@"name", nil]];
    
    NSSortDescriptor *nameSort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[ nameSort ]];
    
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

// Generic method to fetch ordered names (SubjectiveColor, PaintSwatchTypes, and MatchAlgorithm)
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

// Return dictionary keyed by names
//
+ (NSMutableDictionary *)fetchDictByNames:(NSString *)entityName context:(NSManagedObjectContext *)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:@"name", @"order", nil]];
    
    [fetch setResultType: NSDictionaryResultType];
    
    NSError *error = nil;
    NSArray *arrayOfDict    = [context executeFetchRequest:fetch error:&error];
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    for (NSMutableDictionary *dict in arrayOfDict) {
        NSString *name = [dict valueForKey:@"name"];
        NSNumber *order = [dict valueForKey:@"order"];
        
        [results setValue:order forKey:name];
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
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"mix_association == %@", mix_assoc_id]];
    
    NSSortDescriptor *orderSort = [[NSSortDescriptor alloc] initWithKey:@"mix_order" ascending:YES];
    [fetchRequest setSortDescriptors:@[ orderSort ]];
    
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
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"match_association == %@", match_assoc_id]];
    
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
    
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"name == %@", colorName]];
    
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
    
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"order == %@", order]];
    
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
    
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"name == %@", swatchName]];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    if ([results count] == 0) {
        return nil;
    } else {
        return [results objectAtIndex:0];
    }
}

+ (NSArray *)queryPaintSwatchesBySubjColorId:(int)subj_color_id context:(NSManagedObjectContext *)context {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PaintSwatch" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    // Filter out match association swatches
    //
    PaintSwatchType *paintSwatchType = [ManagedObjectUtils queryDictionaryByNameValue:@"PaintSwatchType" nameValue:@"MatchAssoc" context:context];
    int match_assoc_id = [[paintSwatchType order] intValue];
    
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"subj_color_id == %i and type_id != %i", subj_color_id, match_assoc_id]];
    
    SubjectiveColor *subjColor = [self querySubjectiveColorByOrder:[NSNumber numberWithInt:subj_color_id] context:context];

    NSError *error      = nil;
    NSArray *results    = [self sortColors:[context executeFetchRequest:fetch error:&error] color:[subjColor name]];
    
    if ([results count] == 0) {
        return nil;
    } else {
        return results;
    }
}

+ (NSArray *)sortColors:(NSArray *)colors color:(NSString *)subjColor {

    return [colors sortedArrayUsingComparator:^NSComparisonResult(PaintSwatches* ps1, PaintSwatches* ps2) {
        
        UIColor *col1 = [AppColorUtils colorFromSwatch:ps1];
        CGFloat hue, saturation, brightness, alpha;
        [col1 getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
        CGFloat red1   = [ps1.red floatValue];
        CGFloat green1 = [ps1.green floatValue];
        CGFloat blue1  = [ps1.blue floatValue];
    
        UIColor *col2 = [AppColorUtils colorFromSwatch:ps2];
        CGFloat hue2, saturation2, brightness2, alpha2;
        [col2 getHue:&hue2 saturation:&saturation2 brightness:&brightness2 alpha:&alpha2];
    
        CGFloat red2   = [ps2.red floatValue];
        CGFloat green2 = [ps2.green floatValue];
        CGFloat blue2  = [ps2.blue floatValue];
        
        if ([subjColor isEqualToString:@"Pink"]) {
            if (red1 < red2)
                return NSOrderedAscending;
            else if (red1 > red2)
                return NSOrderedDescending;

        } else if ([subjColor isEqualToString:@"Red"]) {
            if (red1 < red2)
                return NSOrderedAscending;
            else if (red1 > red2)
                return NSOrderedDescending;

        } else if ([subjColor isEqualToString:@"Red Orange"]) {
            if (red1 < red2)
                return NSOrderedAscending;
            else if (red1 > red2)
                return NSOrderedDescending;

        } else if ([subjColor isEqualToString:@"Orange"]) {
            if (red1 < red2)
                return NSOrderedAscending;
            else if (red1 > red2)
                return NSOrderedDescending;

        } else if ([subjColor isEqualToString:@"Copper"]) {
            if (red1 < red2)
                return NSOrderedAscending;
            else if (red1 > red2)
                return NSOrderedDescending;

        } else if ([subjColor isEqualToString:@"Brown"]) {
            if (red1 < red2)
                return NSOrderedAscending;
            else if (red1 > red2)
                return NSOrderedDescending;

        } else if ([subjColor isEqualToString:@"Yellow Orange"]) {
            if (red1 < red2)
                return NSOrderedAscending;
            else if (red1 > red2)
                return NSOrderedDescending;

        } else if ([subjColor isEqualToString:@"Gold"]) {
            if (red1 < red2)
                return NSOrderedAscending;
            else if (red1 > red2)
                return NSOrderedDescending;

        } else if ([subjColor isEqualToString:@"Yellow"]) {
            CGFloat comp1 = red1 + green1;
            CGFloat comp2 = red2 + green2;
            if (comp1 < comp2)
                return NSOrderedAscending;
            else if (comp1 > comp2)
                return NSOrderedDescending;

        } else if ([subjColor isEqualToString:@"Yellow Green"]) {
            if (green1 < green2)
                return NSOrderedAscending;
            else if (green1 > green2)
                return NSOrderedDescending;

        } else if ([subjColor isEqualToString:@"Green"]) {
            if (green1 < green2)
                return NSOrderedAscending;
            else if (green1 > green2)
                return NSOrderedDescending;

        } else if ([subjColor isEqualToString:@"Blue Green"]) {
            if (green1 < green2)
                return NSOrderedAscending;
            else if (green1 > green2)
                return NSOrderedDescending;

        } else if ([subjColor isEqualToString:@"Blue"]) {
            if (blue1 < blue2)
                return NSOrderedAscending;
            else if (blue1 > blue2)
                return NSOrderedDescending;

        } else if ([subjColor isEqualToString:@"Blue Violet"]) {
            if (blue1 < blue2)
                return NSOrderedAscending;
            else if (blue1 > blue2)
                return NSOrderedDescending;

        } else if ([subjColor isEqualToString:@"Violet"]) {
            if (blue1 < blue2)
                return NSOrderedAscending;
            else if (blue1 > blue2)
                return NSOrderedDescending;

        } else if ([subjColor isEqualToString:@"Red Violet"]) {
            CGFloat comp1 = red1 + blue1;
            CGFloat comp2 = red2 + blue2;
            if (comp1 < comp2)
                return NSOrderedAscending;
            else if (comp1 > comp2)
                return NSOrderedDescending;

        } else if ([subjColor isEqualToString:@"Cream"]) {
            CGFloat comp1 = red1 + green1 * 0.992 + blue1 * 0.816;
            CGFloat comp2 = red2 + green2 * 0.992 + blue2 * 0.816;
            if (comp1 < comp2)
                return NSOrderedAscending;
            else if (comp1 > comp2)
                return NSOrderedDescending;

        } else if ([subjColor isEqualToString:@"Grey"]) {
            CGFloat comp1 = red1 + green1 + blue1;
            CGFloat comp2 = red2 + green2 + blue2;
            if (comp1 < comp2)
                return NSOrderedAscending;
            else if (comp1 > comp2)
                return NSOrderedDescending;
        }
            
            return NSOrderedSame;
        }];
}

+ (Keyword *)queryKeyword:(NSString *)keyword context:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Keyword" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == [c] %@", keyword]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return [results objectAtIndex:0];
    } else {
        return nil;
    }
}


+ (MixAssociation *)queryMixAssociation:(int)mix_assoc_id context:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MixAssociation" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"objectID == %i", mix_assoc_id]];
    
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
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"paint_swatch == %@", swatch_id]];
    
    NSSortDescriptor *orderSort = [[NSSortDescriptor alloc] initWithKey:@"mix_order" ascending:YES];
    [fetchRequest setSortDescriptors:@[ orderSort ]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return (NSMutableArray *)results;
    } else {
        return nil;
    }
}


// Generic query methods
//
+ (id)queryObjectKeyword:(NSManagedObjectID *)keyword_id objId:(NSManagedObjectID *)obj_id relationName:(NSString *)relationName entityName:(NSString *)entityName context:(NSManagedObjectContext *)context {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"keyword == %@ and %K == %@", keyword_id, relationName, obj_id]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return [results objectAtIndex:0];
    } else {
        return nil;
    }
}

+ (NSArray *)queryEntityRelation:(NSManagedObjectID *)obj_id relationName:(NSString *)relationName entityName:(NSString *)entityName context:(NSManagedObjectContext *)context {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", relationName, obj_id]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return results;
    } else {
        return nil;
    }
}

// Query dictionary name
//
+ (id)queryDictionaryName:(NSString *)entityName entityId:(int)entityId context:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"order == %i", entityId]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return [results objectAtIndex:0];
    } else {
        return nil;
    }
}

+ (id)queryDictionaryByNameValue:(NSString *)entityName nameValue:(NSString *)nameValue context:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@", nameValue]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return [results objectAtIndex:0];
    } else {
        return nil;
    }
}

// Match Association
//
+ (NSMutableArray *)getManualOverrideSwatches:(PaintSwatches *)refObj tapIndex:(int)tapIndex matchAssociation:(MatchAssociations *)matchAssociation context:(NSManagedObjectContext *)context {
    NSArray *tapAreaObjects = [ManagedObjectUtils queryTapAreas:matchAssociation.objectID context:context];
    TapArea *tapArea = [tapAreaObjects objectAtIndex:tapIndex];
    NSArray *tapAreaSwatches = [tapArea.tap_area_swatch allObjects];
    int maxMatchNum = (int)[tapAreaSwatches count];
    
    NSMutableArray *tmpSwatches = [[NSMutableArray alloc] init];
    [tmpSwatches addObject:refObj];
    for (int i=0; i<maxMatchNum; i++) {
        TapAreaSwatch *tapAreaSwatch = [tapAreaSwatches objectAtIndex:i];
        PaintSwatches *paintSwatch   = (PaintSwatches *)[tapAreaSwatch paint_swatch];
        [tmpSwatches addObject:paintSwatch];
    }
    
    return [tmpSwatches mutableCopy];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Existence check methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Existence check methods

+ (BOOL)instanceExists:(NSManagedObjectContext *)context entityName:(NSString *)entityName name:(NSString *)name {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@", name]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        return TRUE;
    } else {
        return FALSE;
    }
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Update methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Update methods

+ (void)setEntityReadOnly:(NSString *)entityName isReadOnly:(BOOL)is_readonly context:(NSManagedObjectContext *)context {

    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"is_shipped != %@", [NSNumber numberWithBool:TRUE]]];
    
    NSArray *results = [context executeFetchRequest:fetch error:NULL];
    
    for (PaintSwatches *paintSwatch in results) {
        [paintSwatch setIs_readonly:[NSNumber numberWithBool:is_readonly]];
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// One-time cleanup  methods(re-purpose as needed)
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - One-time cleanup methods

+ (void)setMixAssocTypeId:(NSManagedObjectContext *)context {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MixAssociation" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    NSArray *results = [context executeFetchRequest:fetch error:NULL];
    
    for (MixAssociation *mixAssoc in results) {
        if ([mixAssoc assoc_type_id] == NULL) {
            [mixAssoc setAssoc_type_id:[NSNumber numberWithInt:1]];
        }
    }
}

+ (void)setSwatchCoverageId:(NSManagedObjectContext *)context {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PaintSwatch" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    NSArray *results = [context executeFetchRequest:fetch error:NULL];
    
    for (PaintSwatches *swatch in results) {
        int type_id = [[swatch type_id] intValue];
        if ([swatch coverage_id] == NULL && (type_id == 1 || type_id == 2 || type_id == 5)) {
            [swatch setCoverage_id:[NSNumber numberWithInt:1]];
        }
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Delete methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Delete methods

// Generic
//
+ (void)deleteDictionaryEntity:(NSString *)entityName {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:context]];
    
    NSArray * result = [context executeFetchRequest:fetch error:nil];
    for (id attribute in result)
        [context deleteObject:attribute];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Error deleting: %@\n%@", [error localizedDescription], [error userInfo]);
    } else {
        NSLog(@"Delete of '%@' successful", entityName);
    }
}

+ (void)deleteSwatchKeywords:(PaintSwatches *)swatchObj context:(NSManagedObjectContext *)context {

    NSArray *swatchKeywords = [self queryEntityRelation:swatchObj.objectID relationName:@"paint_swatch" entityName:@"SwatchKeyword" context:context];

    for (SwatchKeyword *swatchKeywordObj in swatchKeywords) {
        if (swatchKeywordObj != nil) {

            Keyword *keywordObj = swatchKeywordObj.keyword;
            [keywordObj removeSwatch_keywordObject:swatchKeywordObj];
            [swatchObj removeSwatch_keywordObject:swatchKeywordObj];
            
            [context deleteObject:swatchKeywordObj];
        }
    }
}

+ (void)deleteTapAreaKeywords:(TapArea *)tapAreaObj context:(NSManagedObjectContext *)context {

    NSArray *tapAreaKeywords = [self queryEntityRelation:tapAreaObj.objectID relationName:@"tap_area" entityName:@"TapAreaKeyword" context:context];
    
    for (TapAreaKeyword *tapAreaKeywordObj in tapAreaKeywords) {
        if (tapAreaKeywordObj != nil) {
            
            Keyword *keywordObj = tapAreaKeywordObj.keyword;
            [keywordObj removeTap_area_keywordObject:tapAreaKeywordObj];
            [tapAreaObj removeTap_area_keywordObject:tapAreaKeywordObj];
            
            [context deleteObject:tapAreaKeywordObj];
        }
    }
}

+ (void)deleteMatchAssocKeywords:(MatchAssociations *)matchAssocObj context:(NSManagedObjectContext *)context {
    
    NSArray *matchAssocKeywords = [self queryEntityRelation:matchAssocObj.objectID relationName:@"match_association" entityName:@"MatchAssocKeyword" context:context];
    
    for (MatchAssocKeyword *matchAssocKeywordObj in matchAssocKeywords) {
        if (matchAssocKeywordObj != nil) {
            
            Keyword *keywordObj = matchAssocKeywordObj.keyword;
            
            [keywordObj removeMatch_assoc_keywordObject:matchAssocKeywordObj];
            [matchAssocObj removeMatch_assoc_keywordObject:matchAssocKeywordObj];
            
            [context deleteObject:matchAssocKeywordObj];
        }
    }
}

+ (void)deleteMixAssocKeywords:(MixAssociation *)mixAssocObj context:(NSManagedObjectContext *)context {

    NSArray *mixAssocKeywords = [self queryEntityRelation:mixAssocObj.objectID relationName:@"mix_association" entityName:@"MixAssocKeyword" context:context];
    
    for (MixAssocKeyword *mixAssocKeywordObj in mixAssocKeywords) {
        if (mixAssocKeywordObj != nil) {
            
            Keyword *keywordObj = mixAssocKeywordObj.keyword;
            
            [keywordObj removeMix_assoc_keywordObject:mixAssocKeywordObj];
            [mixAssocObj removeMix_assoc_keywordObject:mixAssocKeywordObj];
            
            [context deleteObject:mixAssocKeywordObj];
        }
    }
}

+ (void)deletePaintSwatchKeywords:(PaintSwatches *)paintSwatchObj context:(NSManagedObjectContext *)context {
    
    NSArray *paintSwatchKeywords = [self queryEntityRelation:paintSwatchObj.objectID relationName:@"paint_swatch" entityName:@"SwatchKeyword" context:context];
    
    for (SwatchKeyword *swatchKeywordObj in paintSwatchKeywords) {
        if (swatchKeywordObj != nil) {
            
            Keyword *keywordObj = swatchKeywordObj.keyword;
            
            [keywordObj removeSwatch_keywordObject:swatchKeywordObj];
            [paintSwatchObj removeSwatch_keywordObject:swatchKeywordObj];
            
            [context deleteObject:swatchKeywordObj];
        }
    }
}


+ (void)deleteMixAssociation:(MixAssociation *)mixAssocObj context:(NSManagedObjectContext *)context {
    
    // Delete all MixAssociation Keywords and first
    //
    [ManagedObjectUtils deleteMixAssocKeywords:mixAssocObj context:context];
    
    NSArray *mixAssocSwatches = [[mixAssocObj mix_assoc_swatch] allObjects];
    for (MixAssocSwatch *mixAssocSwatch in mixAssocSwatches) {
        PaintSwatches *paintSwatch = (PaintSwatches *)[mixAssocSwatch paint_swatch];
        
        [mixAssocObj removeMix_assoc_swatchObject:mixAssocSwatch];
        
        int mix_assoc_swatch_ct = (int)[[paintSwatch mix_assoc_swatch] count];
        int tap_area_swatch_ct  = (int)[[paintSwatch tap_area_swatch] count];
        
        // Ensure first that this PaintSwatch does not reference another Mix or Match Association
        //
        if ((mix_assoc_swatch_ct == 1) && (tap_area_swatch_ct == 0)) {
            
            // Delete SwatchKeyword elements (though a cascade rule is in place)
            //
            [ManagedObjectUtils deletePaintSwatchKeywords:paintSwatch context:context];
            
            [context deleteObject:paintSwatch];
            
        } else {
            [paintSwatch removeMix_assoc_swatchObject:mixAssocSwatch];
            
            NSLog(@"Cannot delete paint swatch '%@' has it belongs to more than one Mix/Match association", [paintSwatch name]);
        }
        [context deleteObject:mixAssocSwatch];
    }
    
    // Delete the mix association
    //
    [context deleteObject:mixAssocObj];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Cleanup methods
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - Cleanup methods

+ (void)deleteOrphanPaintSwatches:(NSManagedObjectContext *)context {
    // Exclude match assoc types
    //
    PaintSwatchType *matchSwatchType = [ManagedObjectUtils queryDictionaryByNameValue:@"PaintSwatchType" nameValue:@"MatchAssoc" context:context];
    int match_assoc_id = [[matchSwatchType order] intValue];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PaintSwatch" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"type_id != %i", match_assoc_id]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        for (PaintSwatches *paintSwatch in results) {
            NSArray *assoc_relations = [[paintSwatch mix_assoc_swatch] allObjects];
            if ([assoc_relations count] == 0) {
                [context deleteObject:paintSwatch];
            }
        }
    }
}

+ (void)deleteOrphanMixAssocSwatches:(NSManagedObjectContext *)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MixAssocSwatch" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        for (MixAssocSwatch *assocSwatch in results) {
            if ([assocSwatch mix_association] == nil) {
                [context deleteObject:assocSwatch];
            }
        }
    }
}

+ (void)deleteOrphanPaintSwatchKeywords:(NSManagedObjectContext *)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Keyword" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        for (Keyword *keyword in results) {
            if ([keyword swatch_keyword] != nil) {
                NSArray *assoc_swatches = [[keyword swatch_keyword] allObjects];
                if ([assoc_swatches count] == 0) {
                    [context deleteObject:keyword];
                }
            }
        }
    }
}

+ (void)deleteChildlessMatchAssoc:(NSManagedObjectContext *)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MatchAssociation" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        for (MatchAssociations *matchAssoc in results) {
            NSArray *tap_areas = [[matchAssoc tap_area] allObjects];
            if ([tap_areas count] == 0) {
                [context deleteObject:matchAssoc];
            }
        }
    }
}

+ (void)deleteChildlessMixAssoc:(NSManagedObjectContext *)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MixAssociation" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        for (MixAssociation *mixAssoc in results) {
            NSArray *mix_swatches = [[mixAssoc mix_assoc_swatch] allObjects];
            if ([mix_swatches count] == 0) {
                [context deleteObject:mixAssoc];
            }
        }
    }
}


@end
