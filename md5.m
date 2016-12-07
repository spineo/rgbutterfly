#import "md5.h"

@implementation md5

+ (NSString *)md5Hash:(NSString *)path {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if( [fileManager fileExistsAtPath:path isDirectory:nil] ) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5( data.bytes, (CC_LONG)data.length, digest );
        
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        
        for( int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ ) {
            [output appendFormat:@"%02x", digest[i]];
        }
        
        return output;

    } else {
        return @"";
    }
}

@end
