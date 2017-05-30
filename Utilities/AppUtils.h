//
//  AppUtils.h
//  PaintPicker
//
//  Created by Stuart Pineo on 1/27/17.
//  Copyright © 2017 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppUtils : NSObject

+ (int)checkForDBUpdate;

+ (NSString *)updateDBFromRemote;
    + (NSString *)initDBFromBundle:(NSString *)type;

@end
