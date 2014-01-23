#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>

#import "HZAndroidPackage.h"

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
 Generate a preview for file
 
 This function's job is to create preview for designated file
 ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    NSURL *fileURL = (__bridge NSURL *)url;
    if (![[fileURL pathExtension] isEqualToString:@"apk"])
    {
        return noErr;
    }

    HZAndroidPackage *apk = [HZAndroidPackage packageWithPath:[fileURL path]];

    CFDataRef previewData = (__bridge CFDataRef)[androidPackageHTMLPreview(apk) dataUsingEncoding : NSUTF8StringEncoding];

    if (previewData)
    {
        CFDictionaryRef properties = (__bridge CFDictionaryRef)[NSDictionary dictionary];
        QLPreviewRequestSetDataRepresentation(preview, previewData, kUTTypeHTML, properties);
    }

    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
