//
//  HZAndroidPackage.m
//  QuickLookAPK
//
//  Created by Hezi Cohen on 1/21/14.
//  Copyright (c) 2014 Hezi Cohen. All rights reserved.
//

#import "HZAndroidPackage.h"

NSData* dataFromZipPath(NSString* zipFile, NSString* pathInZip)
{
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/unzip"];
    [task setArguments:[NSArray arrayWithObjects: @"-p", zipFile, pathInZip, nil]];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    return data;
}

NSString* androidPackageHTMLPreview(HZAndroidPackage *package)
{
    __block NSMutableString* stringBuilder = [NSMutableString string];

    [stringBuilder appendFormat:@"<h1>%@ %@ (%@)</h1>", package.name, package.versionName, package.versionCode];
    
    NSString* iconBase64 = [package.iconData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [stringBuilder appendFormat:@"<img title='%@' src='data:image/png;base64,%@'>", package.label, iconBase64];

    return stringBuilder;
}

@implementation HZAndroidPackage

+ (instancetype)packageWithPath:(NSString*)path
{
    HZAndroidPackage* apk = [[HZAndroidPackage alloc] init];
    apk.path = path;
    
    [apk load];

    return apk;
}

- (void)load
{
    NSString* aaptPath = [[[NSBundle bundleWithIdentifier:@"com.hezicohen.qlapk"] resourcePath] stringByAppendingPathComponent:@"aapt"];
    
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath:[aaptPath stringByExpandingTildeInPath]];
    [task setArguments:[NSArray arrayWithObjects:@"dump", @"badging", [self path], nil]];
    
    NSPipe* readPipe = [NSPipe pipe];
    [task setStandardOutput:readPipe];
    [task launch];
    
    NSData* apkData = [[readPipe fileHandleForReading] readDataToEndOfFile];
    NSString* apkString = [[NSString alloc] initWithData:apkData
                                                encoding:NSUTF8StringEncoding];
    
    NSError* error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"package: name='(.*)' versionCode='(.*)' versionName='(.*)'"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    [regex enumerateMatchesInString:apkString options:0 range:NSMakeRange(0, apkString.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
     {
         NSRange range = [result rangeAtIndex:1];
         self.name = [apkString substringWithRange:range];
         range = [result rangeAtIndex:2];
         self.versionCode = [apkString substringWithRange:range];
         range = [result rangeAtIndex:3];
         self.versionName = [apkString substringWithRange:range];
    }];
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"application: label='(.*)' icon='(.*)'"
                                                      options:0
                                                        error:&error];
    [regex enumerateMatchesInString:apkString options:0 range:NSMakeRange(0, apkString.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
     {
         NSRange range = [result rangeAtIndex:1];
         self.label = [apkString substringWithRange:range];
         range = [result rangeAtIndex:2];
         self.iconPath = [apkString substringWithRange:range];
         self.iconData = dataFromZipPath(self.path, self.iconPath);
     }];
}

@end
