#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>

@interface md5 : NSObject

+(NSString *)md5Hash:(NSString *)path;

@end
