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

+ (BOOL)fileRemove:(NSString *)filePath fileManager:(NSFileManager *)fileManager {
    if (fileManager == nil)
        fileManager = [NSFileManager defaultManager];
    
    if ([fileManager isDeletableFileAtPath:filePath]) {
        NSError *error = nil;
        [fileManager removeItemAtPath:filePath error:&error];
        while([fileManager isReadableFileAtPath:filePath]) {
            [NSThread sleepForTimeInterval:ASYNC_THREAD_SLEEP];
        }
        if (error == nil) {
            NSLog(@"Successfully removed file '%@'", filePath);
            return TRUE;
            
        } else {
            NSLog(@"File remove error for file '%@', error: %@\n", filePath, [error localizedDescription]);
            return FALSE;
        }
    }
    return FALSE;
}

+ (BOOL)fileRename:(NSString *)srcFilePath destFilePath:(NSString *)destFilePath fileManager:(NSFileManager *)fileManager {
    
    if (fileManager == nil)
        fileManager = [NSFileManager defaultManager];
    
    // Remove first
    //
    if ([self fileRemove:destFilePath fileManager:fileManager] == FALSE) {
        NSLog(@"ERROR: file remove of '%@' failed", destFilePath);
    }
    
    NSError *error = nil;
    [fileManager copyItemAtPath:srcFilePath toPath:destFilePath error:&error];
    
    if (error == nil) {
        NSLog(@"Successfully renamed file '%@' to '%@'", srcFilePath, destFilePath);
        return TRUE;
        
    } else {
        NSLog(@"Rename file '%@' to '%@' failed. ERROR: %@\n", srcFilePath, destFilePath, [error localizedDescription]);
        return FALSE;
    }
}

+ (NSString *)lineFromFile:(NSString *)filePath {
    return [[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}


@end
