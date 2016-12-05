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
+ (void)upgradeLocalDB {
    
    // Source database file (located in the resource area_
    //
    NSString *sourceDBFile = [[NSString alloc] initWithFormat:@"%@/%@", LOCAL_PATH, CURR_STORE];

    // Find the destination path
    //
    NSString *destDBFile    = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:CURR_STORE];
    NSString *destDBShmFile = [destDBFile stringByAppendingString:@"-shm"];
    NSString *destDBWalFile = [destDBFile stringByAppendingString:@"-wal"];
    
    NSLog(@"***** DEST DB FILE=%@", destDBFile);

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ( [fileManager isReadableFileAtPath:sourceDBFile] ) {
        
        // Remove files (including -shm and -wal) first
        //
        NSError *fileRemoveError;
        if ([fileManager fileExistsAtPath:destDBFile]) {
            @try {
                [fileManager removeItemAtPath:destDBFile error:&fileRemoveError];

            } @catch (NSException *exception) {
                NSLog(@"File remove error for file '%@', error: %@\n", destDBFile, [fileRemoveError localizedDescription]);
            }
        }
        
        if ([fileManager fileExistsAtPath:destDBShmFile]) {
            @try {
                [fileManager removeItemAtPath:destDBShmFile error:&fileRemoveError];
                
            } @catch (NSException *exception) {
                NSLog(@"File remove error for file '%@', error: %@\n", destDBShmFile, [fileRemoveError localizedDescription]);
            }
        }
        
        if ([fileManager fileExistsAtPath:destDBWalFile]) {
            @try {
                [fileManager removeItemAtPath:destDBWalFile error:&fileRemoveError];
                
            } @catch (NSException *exception) {
                NSLog(@"File remove error for file '%@', error: %@\n", destDBWalFile, [fileRemoveError localizedDescription]);
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

// Update the database from GitHub (return string is the user status message)
//
+ (NSString *)upgradeDB {
    
    // Find the destination path
    //
    NSString *destDBPath  = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"***** DEST DB PATH=%@", destDBPath);
    
    // Set the destination files for removal
    //
    NSString *destDBFile    = CURR_STORE;
    NSString *destDBOldFile = [destDBFile stringByAppendingString:@"-old"];
    NSString *destDBTmpFile = [destDBFile stringByAppendingString:@"-tmp"];
    NSString *destDBShmFile = [destDBFile stringByAppendingString:@"-shm"];
    NSString *destDBWalFile = [destDBFile stringByAppendingString:@"-wal"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error = nil;
    
    // Attempt cd into data container directory
    //
    @try {
        [fileManager changeCurrentDirectoryPath:destDBPath];

    } @catch (NSException *exception) {
        NSLog(@"Unable to cd into path '%@'\n", destDBPath);
        return @"ERROR UDB1: Unable to access the data container path, please try again";
        
    }
    
    // (1) Remove existing file and get the new version file
    //
    @try {
        [self fileRemove:GIT_VER_FILE fileManager:fileManager];
    } @catch (NSException *exception) {
        return [@"ERROR UDB2: Failed to remove file" stringByAppendingFormat:@" '%@'", GIT_VER_FILE];
    }

    @try {
        [self HTTPGet:[NSString stringWithFormat:@"%@/%@", GIT_URL, GIT_VER_FILE] contentType:VER_CONT_TYPE fileName:GIT_VER_FILE];

    } @catch (NSException *exception) {
        return [@"ERROR UDB3: Failed to HTTP GET file" stringByAppendingFormat:@" '%@'", GIT_VER_FILE];
    }
    
    // Account for asynchronous writes
    //
    NSString *versionNumber = [self lineFromFile:GIT_VER_FILE];
    if ([versionNumber isEqualToString:DB_VERSION] && ! FORCE_UPDATE_DB) {
        return @"WARNING UDB1: Schema and data version are the same. Use 'Force Update' instead.";
    }

    
    // (2) Remove existing file and get the md5 file
    //
    @try {
        [self fileRemove:GIT_MD5_FILE fileManager:fileManager];
    } @catch (NSException *exception) {
        return [@"ERROR UDB2: Failed to remove file" stringByAppendingFormat:@" '%@'", GIT_MD5_FILE];
    }

    @try {
        [self HTTPGet:[NSString stringWithFormat:@"%@/%@", GIT_URL, GIT_MD5_FILE] contentType:MD5_CONT_TYPE fileName:GIT_MD5_FILE];
    } @catch (NSException *exception) {
        return [@"ERROR UDB3: Failed to HTTP GET file" stringByAppendingFormat:@" '%@'", GIT_MD5_FILE];
    }
    
    // (3) Upgrade the sqlite database
    //
    // Remove files -shm and -wal
    //
    [self fileRemove:destDBShmFile fileManager:fileManager];
    [self fileRemove:destDBWalFile fileManager:fileManager];

    
    // Backup the current database file
    //
    @try {
        [self fileRemove:destDBOldFile fileManager:fileManager];
    } @catch (NSException *exception) {
        return [@"ERROR UDB2: Failed to remove file" stringByAppendingFormat:@" '%@'", destDBOldFile];
    }
    
    error = nil;
    @try {
        [fileManager moveItemAtPath:destDBFile toPath:destDBOldFile error:&error];
        NSLog(@"Successfully renamed file '%@' to '%@'", destDBFile, destDBOldFile);
        
    } @catch (NSException *exception) {
        NSLog(@"ERROR: %@\n", [error localizedDescription]);
        return [@"ERROR UDB4: File rename error for file " stringByAppendingFormat:@" '%@' to '%@'", destDBFile, destDBOldFile];
    }
    
    // Download the latest database (as a tmp file)
    //
    @try {
        [self fileRemove:destDBFile fileManager:fileManager];
    } @catch (NSException *exception) {
        return [@"ERROR UDB2: Failed to remove file" stringByAppendingFormat:@" '%@'", destDBFile];
    }
    
    @try {
        [self HTTPGet:[NSString stringWithFormat:@"%@/%@", GIT_URL, GIT_DB_FILE] contentType:DB_CONT_TYPE fileName:destDBFile];
    } @catch (NSException *exception) {
        return [@"ERROR UDB3: Failed to HTTP GET file " stringByAppendingFormat:@" '%@' to '%@'", destDBFile, destDBFile];
    }

    // Rename the tmp file to main database
    //
//    error = nil;
//    @try {
//        [fileManager moveItemAtPath:destDBTmpFile toPath:destDBFile error:&error];
//        NSLog(@"Successfully renamed file '%@' to '%@'", destDBTmpFile, destDBFile);
//
//    } @catch (NSException *exception) {
//        NSLog(@"File rename error for file '%@' to '%@', error: %@\n", destDBTmpFile, destDBFile, [error localizedDescription]);
//        return [@"ERROR UDB4: File rename error for file" stringByAppendingFormat:@" '%@' to '%@'", destDBTmpFile, destDBFile];
//    }
    
    return @"Upgrade was Successful!";
}

// Parameters
// url string
//
+ (void)HTTPGet:(NSString *)urlStr contentType:(NSString *)contentType fileName:(NSString *)fileName {
    
    // Cleanup
    //
    urlStr = [urlStr stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSLog(@"***** URL STR=%@", urlStr);

    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    [request setValue:[[NSString alloc] initWithFormat:@"%@", contentType] forHTTPHeaderField:@"Content-Type"];
    
    NSString *authValue = [NSString stringWithFormat:@"Token %@", GIT_TOKEN];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
        
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if (httpResponse.statusCode == 200) {
                
                NSLog(@"***** Success");
                
                NSError *error = nil;
                @try {
                    [data writeToFile:fileName atomically:YES];
                    
                } @catch(NSException *exception) {
                    NSLog(@"File write error for file '%@', error: %@\n", fileName, [error localizedDescription]);
                }
           }
        }
        dispatch_semaphore_signal(semaphore);

    }];
                            
    [task resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

// Return the user error message, if any
//
+ (void)fileRemove:(NSString *)filePath fileManager:(NSFileManager *)fileManager {
    
    if (fileManager == nil)
        fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    if ([fileManager isDeletableFileAtPath:filePath]) {
        @try {
            [fileManager removeItemAtPath:filePath error:&error];
            while([fileManager isReadableFileAtPath:filePath]) {
                [NSThread sleepForTimeInterval:ASYNC_THREAD_SLEEP];
            }
            NSLog(@"Successfully removed file '%@'", filePath);
            
        } @catch (NSException *exception) {
            NSLog(@"File remove error for file '%@', error: %@\n", filePath, [error localizedDescription]);
        }
    }
}

+ (NSString *)lineFromFile:(NSString *)filePath {
    
    NSString *line = nil;
    while (line == nil) {
        line = [[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        [NSThread sleepForTimeInterval:ASYNC_THREAD_SLEEP];
    }
    return line;
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
