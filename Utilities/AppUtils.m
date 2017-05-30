//
//  AppUtils.m
//  RGButterfly
//
//  Created by Stuart Pineo on 1/27/17.
//  Copyright © 2017 Stuart Pineo. All rights reserved.
//

#import "AppUtils.h"
#import "GlobalSettings.h"
#import "FileUtils.h"
#import "HTTPUtils.h"

@implementation AppUtils

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
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"********** PRE-UPDATE DATABASE PATH=%@ **********", destDBPath);
    
    
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

// Update the database from the REST API (return string is the user status message)
//
+ (NSString *)updateDBFromRemote {
    // Find the destination path
    //
    NSString *destDBPath  = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"********** PRE-UPDATE DATABASE PATH=%@ **********", destDBPath);
    
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
    if ([fileManager fileExistsAtPath:destDBFile]){
        error = nil;
        [fileManager copyItemAtPath:destDBFile toPath:destDBOldFile error:&error];
        if (error == nil) {
            NSLog(@"Successfully renamed file '%@' to '%@'", destDBFile, destDBOldFile);
        } else {
            NSLog(@"ERROR: %@\n", [error localizedDescription]);
            return [@"ERROR UDB5: File rename error for file " stringByAppendingFormat:@" '%@' to '%@'", destDBFile, destDBOldFile];
        }
    }
    
    // Download the latest database to a '-tmp' suffix file
    //
    if ([HTTPUtils HTTPGet:[NSString stringWithFormat:@"%@/%@", DB_REST_URL, DB_FILE] contentType:DB_CONT_TYPE fileName:destDBTmpFile authToken:authToken] == FALSE) {
        return [@"ERROR UDB3: Failed to HTTP GET file " stringByAppendingFormat:@" '%@' to '%@'", destDBFile, destDBTmpFile];
    }
    
    // Verify the MD5 value and, if equal, perform the update (else, leave in place the current snapshot)
    //
    NSString *md5sum = [FileUtils md5Hash:destDBTmpFile fileManager:fileManager];
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
    
// Update the database from the Local BUNDLE (return string is the user status message)
//
+ (NSString *)initDBFromBundle:(NSString *)type {

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
    
    NSString *successMsg = [[NSString alloc] initWithFormat:@"Database %@ was Successful!", type];
    
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
    
    // Get the MD5 file from Bundle
    //
    NSString *bundleMD5File   = [[NSBundle mainBundle] pathForResource:MD5_FILE ofType:nil];
    if (bundleMD5File != NULL) {
        error = nil;
        [fileManager copyItemAtPath:bundleMD5File toPath:MD5_FILE error:&error];
        if (error == nil) {
            NSLog(@"Successfully copied file '%@' to '%@'", bundleMD5File, MD5_FILE);
        } else {
            NSLog(@"ERROR: %@\n", [error localizedDescription]);
            return [@"ERROR UDB11: File copy error for file " stringByAppendingFormat:@" '%@' to '%@'", bundleMD5File, MD5_FILE];
        }
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
    if ([fileManager fileExistsAtPath:destDBFile]){
        error = nil;
        [fileManager copyItemAtPath:destDBFile toPath:destDBOldFile error:&error];
        if (error == nil) {
            NSLog(@"Successfully renamed file '%@' to '%@'", destDBFile, destDBOldFile);
        } else {
            NSLog(@"ERROR: %@\n", [error localizedDescription]);
            return [@"ERROR UDB5: File rename error for file " stringByAppendingFormat:@" '%@' to '%@'", destDBFile, destDBOldFile];
        }
    }
    
    // Get the MD5 file from Bundle
    //
    NSString *bundleDBFile   = [[NSBundle mainBundle] pathForResource:CURR_STORE ofType:nil];
    error = nil;
    [fileManager copyItemAtPath:bundleDBFile toPath:destDBTmpFile error:&error];
    if (error == nil) {
        NSLog(@"Successfully copied file '%@' to '%@'", bundleDBFile, destDBTmpFile);
    } else {
        NSLog(@"ERROR: %@\n", [error localizedDescription]);
        return [@"ERROR UDB11: File copy error for file " stringByAppendingFormat:@" '%@' to '%@'", bundleDBFile, destDBTmpFile];
    }
    
    // Verify the MD5 value and, if equal, perform the update (else, leave in place the current snapshot)
    //
    NSString *md5sum = [FileUtils md5Hash:destDBTmpFile fileManager:fileManager];
    if ([currMd5sum isEqualToString:md5sum]) {
        [FileUtils fileRemove:destDBShmFile fileManager:fileManager];
        [FileUtils fileRemove:destDBWalFile fileManager:fileManager];
        [FileUtils fileRemove:destDBFile fileManager:fileManager];
        
        if ([FileUtils fileRename:destDBTmpFile destFilePath:destDBFile fileManager:fileManager] == TRUE) {
            NSLog(@"Successfully renamed file '%@' to '%@'", destDBTmpFile, destDBFile);
            
            // Update the version number in NSUserDefaults
            //
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *bundleVersFile = [[NSBundle mainBundle] pathForResource:VERSION_FILE ofType:nil];
            NSString *versionNumber = [FileUtils lineFromFile:bundleVersFile];
            if (versionNumber != nil) {
                [userDefaults setValue:versionNumber forKey:DB_VERSION_KEY];
                [userDefaults synchronize];
            }
            
            return successMsg;
            
        } else {
            return [@"ERROR UDB5: File rename error for file " stringByAppendingFormat:@" '%@' to '%@'", destDBTmpFile, destDBFile];
        }
        
    } else {
        return @"Update Failed on md5 (keeping current snapshot, please try again)";
    }
}

@end
