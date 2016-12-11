//
//  FileUtils.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 12/8/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtils : NSObject

+ (void)fileRemove:(NSString *)filePath fileManager:(NSFileManager *)fileManager;
+ (void)fileRename:(NSString *)srcFilePath destFilePath:(NSString *)destFilePath fileManager:(NSFileManager *)fileManager;
+ (NSString *)lineFromFile:(NSString *)filePath;

@end