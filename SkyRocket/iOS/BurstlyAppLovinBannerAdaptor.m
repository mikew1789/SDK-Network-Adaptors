//
//  BurstlyAppLovinBannerAdaptor.m
//
//  Copyright (C) 2013 AppLovin Corporation
//

#if  ! __has_feature(objc_arc)
    #error This file must be compiled with ARC. Use the -fobjc-arc flag in the XCode build phases tab.
#endif

#import "BurstlyApplovinBannerAdaptor.h"

@implementation BurstlyApplovinBannerAdaptor
@synthesize delegate, sdk, adView, bannerRefreshRate;

-(id) initWithSdk:(ALSdk *)appLovinSdk bannerRefreshRate: refreshRate
{
    self = [super init];
    if(self)
    {
        sdk = appLovinSdk;
        bannerRefreshRate = refreshRate;
        
        adView = [[ALAdView alloc] initBannerAdWithSdk:sdk];
        [adView setAdDisplayDelegate:self];
    }
    return self;
}

-(void) loadBannerInBackground
{
    #if DEBUG
    NSLog(@"AppLovin/Burstly Adaptor: Loading banner in background.");
    #endif
    
    [[sdk adService] loadNextAd:[ALAdSize sizeBanner] andNotify:self];
}

-(void) cancelBannerLoading
{
    // This method is unnecessary, and not implemented in the AppLovin SDK.
    // We pre-cache ads, so it doesn't make sense to cancel a preloaded ad.
}

-(void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    #if DEBUG
    NSLog(@"AppLovin/Burstly Adaptor: Passing rendered ad to Burstly SDK.");
    #endif
    
    [adView render:ad];
    [delegate banner:self didLoadAd: adView];
}

-(void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
    NSError* error = [NSError errorWithDomain:@"BurstlyApplovinBannerAdaptor" code:code userInfo:nil];
    [delegate banner:self didFailToLoadAdWithError:error];
}

-(void) ad:(ALAd *)ad wasClickedIn:(UIView *)view
{
    [delegate bannerWasClicked:self];
    [delegate bannerWillPresentFullScreen:self];
    [delegate bannerWillLeaveApplication:self];
}

-(void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view
{
    // Queue next ad load
    [self queueNextAdLoad];
}

-(void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view
{
}

-(void) queueNextAdLoad
{
    [self performSelector:@selector(loadBannerInBackground) withObject:nil afterDelay: [bannerRefreshRate floatValue]];
}

@end
