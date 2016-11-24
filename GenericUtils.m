//
//  GenericUtils.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 2/13/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import "GenericUtils.h"
#import "GlobalSettings.h"

@implementation GenericUtils

+ (NSMutableArray *)trimStrings:(NSArray *)stringList {
    NSMutableArray *trimmedStrings = [[NSMutableArray alloc] init];
    for (NSString *string in stringList) {
        NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [trimmedStrings addObject:trimmedString];
    }
    return trimmedStrings;
}

+ (NSString *)trimString:(NSString *)string {
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return trimmedString;
}

+ (NSString *)removeSpaces:(NSString *)string {
    NSString *noSpacesString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];

    return noSpacesString;
}

+ (NSString *)getCurrDateString {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:currentDate];
}

+ (NSString *)getCurrDateIdentifier {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
    return [dateFormatter stringFromDate:currentDate];
}

// Upgrade the database to the Version used in the local path
//
+ (void)upgradeDB {
    
    // Source database file (located in the resource area_
    //
    NSString *sourceDBFile = [[NSString alloc] initWithFormat:@"%@/%@", LOCAL_PATH, CURR_STORE];


    // Find the destination path
    //
    NSString *destDBFile  = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:CURR_STORE];


    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ( [fileManager isReadableFileAtPath:sourceDBFile] ) {
        
        if ([fileManager fileExistsAtPath:destDBFile]) {
            NSError *fileRemoveError;
            @try {
                [fileManager removeItemAtPath:destDBFile error:&fileRemoveError];

            } @catch (NSException *exception) {
                NSLog(@"File remove error for file '%@', error: %@\n", destDBFile, [fileRemoveError localizedDescription]);
            }
        }
        
        NSError *fileCopyError;
        @try {
            [fileManager copyItemAtPath:sourceDBFile toPath:destDBFile error:&fileCopyError];

        } @catch (NSException *exception) {
            NSLog(@"File copy error at path '%@', error: %@\n", destDBFile, [fileCopyError localizedDescription]);
        }
    }
}

// Test file deployment
//
+ (void)testFileDeployment {
    
    // Source test file (located in the resource area)
    //
    NSString *testFile   = [[NSString alloc] initWithFormat:@"testfile.%@", [self getCurrDateIdentifier]];
    
    //NSString *sourceFile = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:CURR_STORE];
    NSString *sourceFile = [[NSString alloc] initWithFormat:@"%@/%@", @"/var/tmp", testFile];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:sourceFile contents:nil attributes:nil];

    
    
    // Find the destination path
    //
    NSString *destFile  = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:testFile];
    [fileManager createFileAtPath:destFile contents:nil attributes:nil];
    
    NSString *destDBFile  = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:CURR_STORE];
    
    NSLog(@"********** Source File '%@' **********", sourceFile);
    NSLog(@"********** Dest File '%@' **********", destFile);
    NSLog(@"********** Dest DB File '%@' **********", destDBFile);
    
//    if ( [fileManager isReadableFileAtPath:sourceFile] ) {
//        
//        NSError *fileCopyError;
//        @try {
//            [fileManager copyItemAtPath:sourceFile toPath:destFile error:&fileCopyError];
//            
//        } @catch (NSException *exception) {
//            NSLog(@"File copy error at path '%@', error: %@\n", destFile, [fileCopyError localizedDescription]);
//        }
//    }
//
//    if ([fileManager fileExistsAtPath:destFile]) {
//        NSLog(@"********** File '%@' successfully deployed **********", destFile);
//        NSError *fileRemoveError;
//        @try {
//            [fileManager removeItemAtPath:destFile error:&fileRemoveError];
//            NSLog(@"********** File '%@' successfully removed **********", destFile);
//            
//        } @catch (NSException *exception) {
//            NSLog(@"File remove error for file '%@', error: %@\n", destFile, [fileRemoveError localizedDescription]);
//        }
//    }
    
    if ([fileManager fileExistsAtPath:destDBFile]) {
        NSLog(@"********** File '%@' exists **********", destDBFile);
    }
}


@end
