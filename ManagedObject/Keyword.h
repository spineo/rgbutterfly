//
//  Keyword.h
//  RGButterfly
//
//  Created by Stuart Pineo on 4/3/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MatchAssocKeyword, MixAssocKeyword, SwatchKeyword, TapAreaKeyword;

NS_ASSUME_NONNULL_BEGIN

@interface Keyword : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Keyword+CoreDataProperties.h"
