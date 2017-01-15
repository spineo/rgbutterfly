//
//  HTTPUtils.h
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 12/8/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPUtils : NSObject

+ (BOOL)networkIsReachable;
+ (BOOL)HTTPGet:(NSString *)urlStr contentType:(NSString *)contentType fileName:(NSString *)fileName;

@end
