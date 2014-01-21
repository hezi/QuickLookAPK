#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>

#import "HZAndroidPackage.h"

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    NSURL* fileURL = (__bridge NSURL*)url;
    if (![[fileURL pathExtension] isEqualToString:@"apk"]) {
        return noErr;
    }
    
    HZAndroidPackage *apk = [HZAndroidPackage packageWithPath:[fileURL path]];
    
    CFDataRef previewData = (__bridge CFDataRef)apk.iconData;
    
    if (previewData) {
        CFDictionaryRef properties = (__bridge CFDictionaryRef)[NSDictionary dictionary];
        QLThumbnailRequestSetImageWithData(thumbnail, previewData, properties);
    }
    
    return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    // Implement only if supported
}
