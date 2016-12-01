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

// Update the database from GitHub
//
+ (void)upgradeDB {
    
    // Find the destination path
    //
    NSString *destDBPath  = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"***** DEST DB PATH=%@", destDBPath);
    
    // Set the destination files for removal
    //
    NSString *destDBFile    = [destDBPath stringByAppendingPathComponent:CURR_STORE];
    NSString *destDBOldFile = [destDBFile stringByAppendingString:@"-old"];
    NSString *destDBTmpFile = [destDBFile stringByAppendingString:@"-tmp"];
    NSString *destDBShmFile = [destDBFile stringByAppendingString:@"-shm"];
    NSString *destDBWalFile = [destDBFile stringByAppendingString:@"-wal"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *cdError;
    @try {
        [fileManager changeCurrentDirectoryPath:destDBPath];

    } @catch (NSException *exception) {
        NSLog(@"Unable to cd into path '%@', error: %@\n", destDBPath, [cdError localizedDescription]);
    }
    
    // (1) Get the version file
    //
    NSString *verUrlStr = [NSString stringWithFormat:@"%@/%@", GIT_URL, GIT_VER_FILE];
    @try {
        [self HTTPGet:verUrlStr contentType:VER_CONT_TYPE fileName:GIT_VER_FILE];
    } @catch (NSException *exception) {
        NSLog(@"Failed to get '%@'", GIT_VER_FILE);
    }
    
    // (2) Get the md5 file
    //
    NSString *md5UrlStr = [NSString stringWithFormat:@"%@/%@", GIT_URL, GIT_MD5_FILE];
    @try {
        [self HTTPGet:md5UrlStr contentType:MD5_CONT_TYPE fileName:GIT_MD5_FILE];
    } @catch (NSException *exception) {
        NSLog(@"Failed to get '%@'", GIT_MD5_FILE);
    }
    
    // (3) Upgrade the sqlite database
    //
    // Remove files -shm and -wal
    //
    NSError *fileRemoveError = nil;
    if ([fileManager fileExistsAtPath:destDBShmFile]) {
        @try {
            [fileManager removeItemAtPath:destDBShmFile error:&fileRemoveError];
            NSLog(@"Successfully removed file '%@'", destDBShmFile);
            
        } @catch (NSException *exception) {
            NSLog(@"File remove error for file '%@', error: %@\n", destDBShmFile, [fileRemoveError localizedDescription]);
        }
    }
    
    if ([fileManager fileExistsAtPath:destDBWalFile]) {
        @try {
            [fileManager removeItemAtPath:destDBWalFile error:&fileRemoveError];
            NSLog(@"Successfully removed file '%@'", destDBWalFile);
            
        } @catch (NSException *exception) {
            NSLog(@"File remove error for file '%@', error: %@\n", destDBWalFile, [fileRemoveError localizedDescription]);
        }
    }
    
    // Backup the current database file
    //
    NSError *fileMoveError = nil;
    if ([fileManager fileExistsAtPath:destDBOldFile]) {
        @try {
            [fileManager removeItemAtPath:destDBOldFile error:&fileRemoveError];
            [fileManager copyItemAtPath:destDBFile toPath:destDBOldFile error:&fileMoveError];
            NSLog(@"Successfully renamed file '%@' to '%@'", destDBFile, destDBOldFile);
            
        } @catch (NSException *exception) {
            NSLog(@"File rename error for file '%@' to '%@', error: %@\n", destDBFile, destDBOldFile, [fileMoveError localizedDescription]);
        }
    }
    
    // Download the latest database (as a tmp file)
    //
    NSString *dbUrlStr = [NSString stringWithFormat:@"%@/%@", GIT_URL, GIT_DB_FILE];
    @try {
        [self HTTPGet:dbUrlStr contentType:DB_CONT_TYPE fileName:destDBTmpFile];
    } @catch (NSException *exception) {
        NSLog(@"Failed to get '%@'", destDBTmpFile);
    }
    
    // Rename the tmp file to main database
    //
    fileMoveError = nil;
    @try {
        [fileManager removeItemAtPath:destDBFile error:&fileRemoveError];
        [fileManager copyItemAtPath:destDBTmpFile toPath:destDBFile error:&fileMoveError];
        NSLog(@"Successfully renamed file '%@' to '%@'", destDBTmpFile, destDBFile);
        
    } @catch (NSException *exception) {
        NSLog(@"File rename error for file '%@' to '%@', error: %@\n", destDBTmpFile, destDBFile, [fileMoveError localizedDescription]);
    }
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
    
    NSError *error = nil;
    if (!error) {
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                if (httpResponse.statusCode == 200) {
                    
                    NSLog(@"***** Success");
                    
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    
                    // Remove file before writing to it
                    //
                    NSError *fileRemoveError = nil;
                    if ([fileManager fileExistsAtPath:fileName]) {
                        @try {
                            [fileManager removeItemAtPath:fileName error:&fileRemoveError];
                            NSLog(@"Successfully removed file '%@'", fileName);
                            
                        } @catch (NSException *exception) {
                            NSLog(@"File remove error for file '%@', error: %@\n", fileName, [fileRemoveError localizedDescription]);
                        }
                    }
                    
                    while (! [fileManager fileExistsAtPath:fileName]) {
                        [data writeToFile:fileName atomically:YES];
                        
                        [NSThread sleepForTimeInterval:.5];
                    }
                    
                } else {
                    NSLog(@"***** ERROR: StatusCode=%i, Description=%@, DebugDescription=%@", (int)httpResponse.statusCode, httpResponse.description, httpResponse.debugDescription);
                }
            }
        }] resume];
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
