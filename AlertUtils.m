//
//  AlertUtils.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 11/15/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "AlertUtils.h"
#import "GlobalSettings.h"

@implementation AlertUtils

+ (UIAlertView *)createOkAlert:(NSString *)title message:(NSString *)message {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title
                                    message: message
                                    delegate:self
                                    cancelButtonTitle:@"Ok"
                                    otherButtonTitles: nil];
    [alert setTintColor: DARK_TEXT_COLOR];
    
    return alert;
}

// The alert text set in GlobalSettings
//
+ (void)noValueAlert {
    [[AlertUtils createOkAlert: NO_VALUE message: NO_VALUE_MSG] show];
}

+ (void)sizeLimitAlert:(int)size {
    [[AlertUtils createOkAlert: SIZE_LIMIT message: [[NSString alloc] initWithFormat: SIZE_LIMIT_MSG, size]] show];
}

+ (void)rowLimitAlert:(int)size {
    [[AlertUtils createOkAlert: ROW_LIMIT message: [[NSString alloc] initWithFormat: ROW_LIMIT_MSG, size]] show];
}

+ (void)valueExistsAlert {
    [[AlertUtils createOkAlert: VALUE_EXISTS message: VALUE_EXISTS_MSG] show];
}

@end
