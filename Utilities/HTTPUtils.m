//
//  HTTPUtils.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 12/8/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//

#import "HTTPUtils.h"
#import "GlobalSettings.h"
#import "FileUtils.h"
#import "Reachability.h"
#import "NSData+Base64.h"

@implementation HTTPUtils

// Check for network connectivity
//
+ (BOOL)networkIsReachable {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return FALSE;
    } else {
        return TRUE;
    }
}

// HTTP Get wrapper
//
+ (int)HTTPGet:(NSString *)urlStr contentType:(NSString *)contentType fileName:(NSString *)fileName {
    
    __block int stat = 1;
    
    // Cleanup
    //
    urlStr = [urlStr stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    request.HTTPMethod = @"GET";
    [request setValue:[[NSString alloc] initWithFormat:@"%@", contentType] forHTTPHeaderField:@"Content-Type"];

    // Add a file check
    //
    NSString* filePath = [[NSBundle mainBundle] pathForResource:GIT_TOKEN_FILE ofType:@"txt"];

    NSString *gitToken;
    NSError *error = nil;
    @try {
        gitToken = [FileUtils lineFromFile:filePath];
    } @catch(NSException *exception) {
        NSLog(@"Failed to get the GIT token from file '%@', error: %@\n", filePath, [error localizedDescription]);
        return stat;
    }

    NSData *authData = [gitToken dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodingWithLineLength:80]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            NSError *error = nil;
            if (httpResponse.statusCode == 200) {
                @try {
                    [data writeToFile:fileName atomically:YES];
                    stat = 0;
                
                } @catch(NSException *exception) {
                    NSLog(@"File write error for file '%@', error: %@\n", fileName, [error localizedDescription]);

                }
            }
        }
        dispatch_semaphore_signal(semaphore);
        
    }];
    
    [task resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return stat;
}


@end
