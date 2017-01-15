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
    if ([FileUtils fileRemove:GIT_VER_FILE fileManager:fileManager] == FALSE) {
        NSLog(@"Unable to remove file '%@'\n", GIT_VER_FILE);
        return 1;
    }
    
    if ([HTTPUtils HTTPGet:[NSString stringWithFormat:@"%@/%@", DB_REST_URL, GIT_VER_FILE] contentType:VER_CONT_TYPE fileName:GIT_VER_FILE] == 1) {
        return 1;
    }
    
    // Account for asynchronous writes
    //
    NSString *versionNumber = [FileUtils lineFromFile:GIT_VER_FILE];
    if (versionNumber == nil) {
        NSLog(@"Failed to retrieve the version number for file '%@'\n", GIT_VER_FILE);
        return 1;
    }

    // NSUserDefaults
    //
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currVersionNumber  = [userDefaults stringForKey:DB_VERSION_KEY];
    
    NSLog(@"***** New Version Number=%@", versionNumber);

    if (! (currVersionNumber && [versionNumber isEqualToString:currVersionNumber])) {
        
        // Store the Version in NSUserDefaults
        //
        [userDefaults setValue:versionNumber forKey:DB_VERSION_KEY];
        [userDefaults synchronize];
        
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
    if ([FileUtils fileRemove:GIT_MD5_FILE fileManager:fileManager] == FALSE) {
        return [@"ERROR UDB2: Failed to remove file" stringByAppendingFormat:@" '%@'", GIT_MD5_FILE];
    }

    if ([HTTPUtils HTTPGet:[NSString stringWithFormat:@"%@/%@", DB_REST_URL, GIT_MD5_FILE] contentType:MD5_CONT_TYPE fileName:GIT_MD5_FILE] == 1) {
        return [@"ERROR UDB3: Failed to HTTP GET file" stringByAppendingFormat:@" '%@'", GIT_MD5_FILE];
    }
    
    // Perform the check once the updated database is downloaded
    //
    NSString *currMd5sum = [FileUtils lineFromFile:GIT_MD5_FILE];
    if (currMd5sum == nil) {
        return [@"ERROR UDB4: Failed to read file" stringByAppendingFormat:@" '%@'", GIT_MD5_FILE];
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
    if ([HTTPUtils HTTPGet:[NSString stringWithFormat:@"%@/%@", DB_REST_URL, GIT_DB_FILE] contentType:DB_CONT_TYPE fileName:destDBTmpFile] == 1) {
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
            return successUpdMsg;
            
        } else {
            return [@"ERROR UDB5: File rename error for file " stringByAppendingFormat:@" '%@' to '%@'", destDBTmpFile, destDBFile];
        }

    } else {
        return @"Update Failed on md5 (keeping current snapshot, please try again)";
    }
    
    return successUpdMsg;
}

@end
