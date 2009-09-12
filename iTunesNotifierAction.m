//
//  iTunesNotifierAction.m
//  iTunesNotifier
//
//  Created by Andrew Wason on 9/12/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <Vermilion/Vermilion.h>

@interface iTunesNotifierAction : HGSAction
@end

@implementation  iTunesNotifierAction

// Perform an action given a dictionary of info. For now, we are just passing
// in an array of direct objects, but there may be more keys added to future
// SDKs
- (BOOL)performWithInfo:(NSDictionary*)info {
  HGSResultArray *directObjects
    = [info objectForKey:kHGSActionDirectObjectsKey];
  BOOL success = NO;
  if (directObjects) {
    NSString *name = [directObjects displayName];
    NSString *localizedOK = HGSLocalizedString(@"OK", nil);
    NSString *localizedFormat = HGSLocalizedString(@"Action performed on %@",
                                                   nil);
    [NSAlert alertWithMessageText:NSStringFromClass([self class])
                    defaultButton:localizedOK
                   alternateButton:nil
                       otherButton:nil
         informativeTextWithFormat:localizedFormat, name];
    success = YES;
  }
  return success;
}
@end
