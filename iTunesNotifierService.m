//
//  iTunesNotifierAction.m
//  iTunesNotifier
//
//  Copyright Andrew Wason 2009. All rights reserved.
//

#import <Vermilion/Vermilion.h>
#import <GTM/GTMNSAppleScript+Handler.h>

static NSString *const kiTunesPlayerInfoNotification = @"com.apple.iTunes.playerInfo";

@interface iTunesNotifierService : HGSExtension {
    NSAppleScript *script;
}

- (void)iTunesPlayerInfoNotification:(NSNotification *)notification;
- (NSImage *)getTrackArtwork;
@end


@implementation iTunesNotifierService

- (id)initWithConfiguration:(NSDictionary *)configuration {
    if ((self = [super initWithConfiguration:configuration]) == nil)
        return nil;

    // Load AppleScript
    NSBundle *bundle = HGSGetPluginBundle();
    NSString *path = [bundle pathForResource:@"iTunesGetArtwork"
                                      ofType:@"scpt"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSDictionary *error = nil;
    script = [[NSAppleScript alloc] initWithContentsOfURL:url error:&error];
    if (!script) {
        HGSLogDebug(@"Unable to load script: %@ error: %@", url, error);
        [self release];
        return nil;
    }

    // Register for iTunes track change notifications
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(iTunesPlayerInfoNotification:)
                                                            name:kiTunesPlayerInfoNotification
                                                          object:nil];
    return self;
}

- (void)dealloc {
    [script release];
    [super dealloc];
}

- (void)iTunesPlayerInfoNotification:(NSNotification *)notification {
    NSDictionary *notificationInfo = [notification userInfo];
    NSString *state = [notificationInfo objectForKey:@"Player State"];
    if (![state isEqualToString:@"Playing"])
        return;

    NSMutableDictionary *messageDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [messageDict setObject:[notificationInfo objectForKey:@"Artist"]
                    forKey:kHGSSummaryMessageKey];
    [messageDict setObject:[self getTrackArtwork]
                    forKey:kHGSImageMessageKey];
    [messageDict setObject:[notificationInfo objectForKey:@"Name"]
                    forKey:kHGSDescriptionMessageKey];
    
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kHGSUserMessageNotification
                      object:self
                    userInfo:messageDict];
}

- (NSImage *)getTrackArtwork {
    NSDictionary *error = nil;
    NSAppleEventDescriptor *result =
        [script gtm_executePositionalHandler:@"getTrackArtwork"
                                  parameters:nil
                                       error:&error];
    NSImage *artwork = nil;
    if (error)
        HGSLog(@"iTunes script failed %@", [error description]);
    else
        artwork = [[[NSImage alloc] initWithData:[result data]] autorelease];
    return artwork;
}

@end
