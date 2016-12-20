//
//  FileUtils.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 12/8/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import "FileUtils.h"
#import "GlobalSettings.h"

@implementation FileUtils

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

+ (void)fileRename:(NSString *)srcFilePath destFilePath:(NSString *)destFilePath fileManager:(NSFileManager *)fileManager {
    
    if (fileManager == nil)
        fileManager = [NSFileManager defaultManager];
    
    // Remove first
    //
    @try {
        [self fileRemove:destFilePath fileManager:fileManager];
    } @catch (NSException *exception) {
        NSLog(@"ERROR: file remove failed");
    }
    
    NSError *error = nil;
    @try {
        [fileManager copyItemAtPath:srcFilePath toPath:destFilePath error:&error];
        NSLog(@"Successfully renamed file '%@' to '%@'", srcFilePath, destFilePath);
        
    } @catch (NSException *exception) {
        NSLog(@"ERROR: %@\n", [error localizedDescription]);
    }
}

+ (NSString *)lineFromFile:(NSString *)filePath {
    return [[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}


@end
