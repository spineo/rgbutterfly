//
//  GenericUtils.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 2/13/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import "GenericUtils.h"
#import "GlobalSettings.h"
#import "md5.h"
#import "FileUtils.h"
#import "HTTPUtils.h"

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

// Check the GITHUB version file to determine if a database update is available
//
// Update Stat Values
// 0 - Update not needed
// 1 - Update checks failed
// 2 - Successfully verified that update is needed
//
+ (int)checkForDBUpdate {
    
    // Find the destination path
    //
    NSString *destDBPath  = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"***** Data Container Path=%@", destDBPath);
    NSFileManager *fileManager = [NSFileManager defaultManager];

    
    // Attempt cd into data container directory
    //
    if ([fileManager changeCurrentDirectoryPath:destDBPath] == NO) {
        NSLog(@"Unable to cd into path '%@'\n", destDBPath);
        return 1;
    }
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // (1) Remove existing file and get the new version file
    //
    if ([FileUtils fileRemove:VERSION_FILE fileManager:fileManager] == FALSE) {
        NSLog(@"Unable to remove file '%@'\n", VERSION_FILE);
    }
    
    // Authtoken
    //
    NSString *authToken = [FileUtils lineFromFile:[[NSBundle mainBundle] pathForResource:AUTHTOKEN_FILE ofType:@"txt"]];
    if ([HTTPUtils HTTPGet:[NSString stringWithFormat:@"%@/%@", DB_REST_URL, VERSION_FILE] contentType:VER_CONT_TYPE fileName:VERSION_FILE authToken:authToken] == FALSE) {
        return 1;
    }
    
    // Version number
    //
    NSString *versionNumber = [FileUtils lineFromFile:VERSION_FILE];
    if (versionNumber == nil) {
        NSLog(@"Failed to retrieve the version number for file '%@'\n", VERSION_FILE);
        return 1;
    }

    // NSUserDefaults
    //
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currVersionNumber  = [userDefaults stringForKey:DB_VERSION_KEY];
    
    NSLog(@"***** New Version Number=%@", versionNumber);

    if (! (currVersionNumber && [versionNumber isEqualToString:currVersionNumber])) {
        return 2;
    }

    return 0;
}

// Update the database from GitHub (return string is the user status message)
//
+ (NSString *)updateDB {
    // Find the destination path
    //
    NSString *destDBPath  = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"********************* DEST DB PATH=%@", destDBPath);
    
    // Set the destination files for removal
    //
    NSString *destDBFile    = CURR_STORE;
    NSString *destDBOldFile = [destDBFile stringByAppendingString:@"-old"];
    NSString *destDBTmpFile = [destDBFile stringByAppendingString:@"-tmp"];
    NSString *destDBShmFile = [destDBFile stringByAppendingString:@"-shm"];
    NSString *destDBWalFile = [destDBFile stringByAppendingString:@"-wal"];
    
    NSString *successUpdMsg = @"Update was Successful!";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error = nil;
    
    // Attempt cd into data container directory
    //
    if ([fileManager changeCurrentDirectoryPath:destDBPath] == NO) {
        NSLog(@"Unable to cd into path '%@'\n", destDBPath);
        return @"ERROR UDB1: Unable to access the data container path, please try again";
        
    }

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // (1) Remove existing file and get the md5 file
    //
    if ([FileUtils fileRemove:MD5_FILE fileManager:fileManager] == FALSE) {
        NSLog(@"ERROR UDB2: Failed to remove file '%@'", MD5_FILE);
    }

    // Authtoken
    //
    NSString *authToken = [FileUtils lineFromFile:[[NSBundle mainBundle] pathForResource:AUTHTOKEN_FILE ofType:@"txt"]];
    if ([HTTPUtils HTTPGet:[NSString stringWithFormat:@"%@/%@", DB_REST_URL, MD5_FILE] contentType:MD5_CONT_TYPE fileName:MD5_FILE authToken:authToken] == FALSE) {
        return [@"ERROR UDB3: Failed to HTTP GET file" stringByAppendingFormat:@" '%@'", MD5_FILE];
    }
    
    // Perform the check once the updated database is downloaded
    //
    NSString *currMd5sum = [FileUtils lineFromFile:MD5_FILE];
    if (currMd5sum == nil) {
        return [@"ERROR UDB4: Failed to read file" stringByAppendingFormat:@" '%@'", MD5_FILE];
    }


    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // (2) Upgrade the sqlite database
    //
    // Remove the -old and -tmp suffix files
    //
    [FileUtils fileRemove:destDBOldFile fileManager:fileManager];
    [FileUtils fileRemove:destDBTmpFile fileManager:fileManager];

    
    // Backup the current database file
    //
    error = nil;
    [fileManager copyItemAtPath:destDBFile toPath:destDBOldFile error:&error];
    if (error == nil) {
        NSLog(@"Successfully renamed file '%@' to '%@'", destDBFile, destDBOldFile);
    } else {
        NSLog(@"ERROR: %@\n", [error localizedDescription]);
        return [@"ERROR UDB5: File rename error for file " stringByAppendingFormat:@" '%@' to '%@'", destDBFile, destDBOldFile];
    }
    
    // Download the latest database to a '-tmp' suffix file
    //
    if ([HTTPUtils HTTPGet:[NSString stringWithFormat:@"%@/%@", DB_REST_URL, DB_FILE] contentType:DB_CONT_TYPE fileName:destDBTmpFile authToken:authToken] == FALSE) {
        return [@"ERROR UDB3: Failed to HTTP GET file " stringByAppendingFormat:@" '%@' to '%@'", destDBFile, destDBTmpFile];
    }
    
    // Verify the MD5 value and, if equal, perform the update (else, leave in place the current snapshot)
    //
    NSString *md5sum = [md5 md5Hash:destDBTmpFile];
    if ([currMd5sum isEqualToString:md5sum]) {
        [FileUtils fileRemove:destDBShmFile fileManager:fileManager];
        [FileUtils fileRemove:destDBWalFile fileManager:fileManager];
        [FileUtils fileRemove:destDBFile fileManager:fileManager];
            
        if ([FileUtils fileRename:destDBTmpFile destFilePath:destDBFile fileManager:fileManager] == TRUE) {
            NSLog(@"Successfully renamed file '%@' to '%@'", destDBTmpFile, destDBFile);
            
            // Update the version number in NSUserDefaults
            //
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *versionNumber = [FileUtils lineFromFile:VERSION_FILE];
            if (versionNumber != nil) {
                [userDefaults setValue:versionNumber forKey:DB_VERSION_KEY];
                [userDefaults synchronize];
            }
            
            return successUpdMsg;
            
        } else {
            return [@"ERROR UDB5: File rename error for file " stringByAppendingFormat:@" '%@' to '%@'", destDBTmpFile, destDBFile];
        }

    } else {
        return @"Update Failed on md5 (keeping current snapshot, please try again)";
    }
}

@end
