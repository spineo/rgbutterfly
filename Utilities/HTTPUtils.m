//
//  HTTPUtils.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 12/8/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import "HTTPUtils.h"
#import "GlobalSettings.h"

@implementation HTTPUtils

// HTTP Get wrapper
//
+ (void)HTTPGet:(NSString *)urlStr contentType:(NSString *)contentType fileName:(NSString *)fileName {
    
    // Cleanup
    //
    urlStr = [urlStr stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
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


@end
