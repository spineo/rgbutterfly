//
//  AlertUtils.m
//  RGButterfly
//
//  Created by Stuart Pineo on 11/15/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "AlertUtils.h"
#import "GlobalSettings.h"


@implementation AlertUtils


// Replace with UIAlertController (see 'takePhoto' example in 'ViewController')
//
+ (UIAlertController *)createOkAlert:(NSString *)title message:(NSString *)message {
    
    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:title
                                                                         message:message
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* OKButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:nil];
    
    [myAlertController addAction:OKButton];
    
    return myAlertController;
}

+ (UIAlertController *)createNoShowAlert:(NSString *)title message:(NSString *)message key:(NSString *)key {
    
    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:title
                                                                               message:message
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* NoShowButton = [UIAlertAction
                               actionWithTitle:@"Do not show this alert again"
                               style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                       [userDefaults setBool:FALSE forKey:key];
                                       [userDefaults synchronize];
                                   }];
    
    UIAlertAction* OKButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:nil];
    
    [myAlertController addAction:NoShowButton];
    [myAlertController addAction:OKButton];
    
    return myAlertController;
}


// The alert text set in GlobalSettings
//
+ (UIAlertController *)noValueAlert {
    return [self createOkAlert:NO_VALUE message:NO_VALUE_MSG];
}

+ (UIAlertController *)noSaveAlert {
    return [self createOkAlert:NO_SAVE message:NO_SAVE_MSG];
}

+ (UIAlertController *)sizeLimitAlert:(int)size {
    return [self createOkAlert:SIZE_LIMIT message:[[NSString alloc] initWithFormat:SIZE_LIMIT_MSG, size]];
}

+ (UIAlertController *)rowLimitAlert:(int)size {
    return [self createOkAlert:ROW_LIMIT message:[[NSString alloc] initWithFormat:ROW_LIMIT_MSG, size]];
}

+ (UIAlertController *)valueExistsAlert {
    return [self createOkAlert:VALUE_EXISTS message:VALUE_EXISTS_MSG];
}

+ (UIAlertController *)createBlankAlert:(NSString *)title message:(NSString *)message {
    
    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:title
                                                                               message:message
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    return myAlertController;
}

@end
