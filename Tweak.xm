#import <substrate.h>

#define ARC4RANDOM_MAX      0x100000000
static NSString *const kTINCPreferencesDomain = @"com.ridn.tinc";

CGFloat redValue;
CGFloat blueValue;
CGFloat greenValue;
BOOL tincRandom;

NSUserDefaults *tincUserDefaults;

%hook SBNotificationCenterViewController
-(void)viewWillAppear:(BOOL)arg1 {
  [tincUserDefaults synchronize];
  
  redValue = [[tincUserDefaults objectForKey: @"r"]floatValue];
  greenValue = [[tincUserDefaults objectForKey: @"g"]floatValue];
  blueValue = [[tincUserDefaults objectForKey: @"b"]floatValue];
  tincRandom = [tincUserDefaults boolForKey: @"random"];

  %orig;
  id tincTintView = MSHookIvar<id>(self,"_tintView");
  if(tincRandom) {
    [tincTintView setBackgroundColor: [UIColor colorWithRed: (double)arc4random() / ARC4RANDOM_MAX green:(double)arc4random() / ARC4RANDOM_MAX blue:(double)arc4random() / ARC4RANDOM_MAX alpha: .35]];
  }else{
    [tincTintView setBackgroundColor: [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha: .35]];

  }
}

%end
static void reloadSettingsNotification(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo) {
  [tincUserDefaults synchronize];

}
%ctor {
  %init();

	tincUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:kTINCPreferencesDomain];
  [tincUserDefaults registerDefaults:@{
    @"random":@NO,
    @"r": @0.0,
    @"g": @0.0,
    @"b": @0.0
  }];
  [tincUserDefaults synchronize];

  redValue = [[tincUserDefaults objectForKey: @"r"]floatValue];
  greenValue = [[tincUserDefaults objectForKey: @"g"]floatValue];
  blueValue = [[tincUserDefaults objectForKey: @"b"]floatValue];
  tincRandom = [tincUserDefaults boolForKey: @"random"];

   //CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),NULL, (CFNotificationCallback)reloadSettingsNotification, CFSTR("com.ridn.cheader/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
   CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, reloadSettingsNotification, CFSTR("com.ridn.tinc/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);


}
