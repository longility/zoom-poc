//
//  RCTZoomMeeting.m
//  ZoomPoc
//
//  Created by Long Mai on 2/7/22.
//

#import <Foundation/Foundation.h>
#import "RCTZoomMeeting.h"

@implementation RCTZoomMeeting
{
  bool hasListeners;
}

- (instancetype)init {
  if (self = [super init]) {
  }
  return self;
}

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(initialize:(NSDictionary *)settings
                  resolve: (RCTPromiseResolveBlock)resolve
                  reject: (RCTPromiseRejectBlock)reject)
{
  @try {
    MobileRTCSDKInitContext *context = [[MobileRTCSDKInitContext alloc] init];
    
    if([self dictionary:settings hasKey: @"domain"]) context.domain = settings[@"domain"];
    if([self dictionary:settings hasKey: @"enableLog"]) context.enableLog = settings[@"enableLog"];
    if([self dictionary:settings hasKey: @"locale"]) context.locale = (MobileRTC_ZoomLocale)settings[@"locale"];
    
    BOOL initializeSuc = [[MobileRTC sharedRTC]initialize:context];
    
    if (initializeSuc == NO) {
      reject(@"ZOOM_EXCEPTION", @"Initialize context failed.", nil);
      return;
    }
    
    MobileRTCAuthService *authService = [[MobileRTC sharedRTC]getAuthService];
    
    if (authService == nil) {
      reject(@"ZOOM_EXCEPTION", @"No auth service", nil);
      return;
    }
    
    authService.delegate = self;
    
    if([self dictionary:settings hasKey: @"jwtToken"]) authService.jwtToken = settings[@"jwtToken"];
    if([self dictionary:settings hasKey: @"sdkKey"]) authService.clientKey = settings[@"sdkKey"];
    if([self dictionary:settings hasKey: @"sdkSecret"]) authService.clientSecret = settings[@"sdkSecret"];
    
    [authService sdkAuth];
    resolve(nil);
  } @catch (NSError *ex) {
    reject(@"ZOOM_EXCEPTION", @"Failed to initialize", ex);
  }
}

RCT_EXPORT_METHOD(isInitialized: (RCTPromiseResolveBlock)resolve
                  reject: (RCTPromiseRejectBlock)reject)
{
  // unable to find is initialized but this may be good enough for now
  @try {
    BOOL isRTCAuthorized = [[MobileRTC sharedRTC] isRTCAuthorized];
    
    if(!isRTCAuthorized) resolve(@(isRTCAuthorized));
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    resolve(ms ? @(YES) : @(NO));
  } @catch (NSError *ex) {
    reject(@"ZOOM_EXCEPTION", @"Failed to check isInitialized", ex);
  }
}

RCT_EXPORT_METHOD(
                  joinMeeting:(NSDictionary *)settings
                  resolve: (RCTPromiseResolveBlock)resolve
                  reject: (RCTPromiseRejectBlock)reject
                  )
{
  @try {
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms) {
      ms.delegate = self;
      
      MobileRTCMeetingJoinParam * joinParam = [[MobileRTCMeetingJoinParam alloc]init];
      
      if([self dictionary:settings hasKey: @"participantName"]) joinParam.userName = settings[@"participantName"];
      if([self dictionary:settings hasKey: @"meetingID"]) joinParam.meetingNumber = settings[@"meetingID"];
      if([self dictionary:settings hasKey: @"passcode"]) joinParam.password = settings[@"passcode"];
      if([self dictionary:settings hasKey: @"noAudio"]) joinParam.noAudio = settings[@"noAudio"];
      if([self dictionary:settings hasKey: @"noVideo"]) joinParam.noVideo = settings[@"noVideo"];
      
      MobileRTCMeetError joinMeetingResult = [ms joinMeetingWithJoinParam:joinParam];
      if(joinMeetingResult != MobileRTCMeetError_Success) {
        reject(@"ZOOM_EXCEPTION", [NSString stringWithFormat:@"Join meeting error with result: %lu", joinMeetingResult], nil);
        return;
      }
      resolve(nil);
    } else {
      reject(@"ZOOM_EXCEPTION", @"Meeting service is not initialized.", nil);
    }
  } @catch (NSError *ex) {
    reject(@"ZOOM_EXCEPTION", @"Executing joinMeeting", ex);
  }
}

RCT_EXPORT_METHOD(connectAudio: (RCTPromiseResolveBlock)resolve
                  reject: (RCTPromiseRejectBlock)reject)
{
  @try {
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (!ms)
    {
      reject(@"ZOOM_EXCEPTION", @"No meeting service to connect audio", nil);
      return;
    }
    [ms connectMyAudio: YES];
    [ms muteMyAudio: NO];
    resolve(nil);
  } @catch (NSError *ex) {
    reject(@"ZOOM_EXCEPTION", @"Failed to connect audio", ex);
  }
}

// Will be called when this module's first listener is added.
-(void)startObserving {
  hasListeners = YES;
  // Set up any upstream listeners or background tasks as necessary
}

// Will be called when this module's last listener is removed, or on dealloc.
-(void)stopObserving {
  hasListeners = NO;
  // Remove upstream listeners, stop unnecessary background tasks
}

- (void)onMobileRTCAuthReturn:(MobileRTCAuthError)returnValue {
  if(hasListeners == NO) return;
  
  [self sendEventWithName:@"any" body:@"onMobileRTCAuthReturn"];
}

- (void)onMobileRTCAuthExpired {
  if(hasListeners == NO) return;
  [self sendEventWithName:@"any" body:@"onMobileRTCAuthExpired"];
}

/*!
 @brief Callback event that the current user's hand state changes.
 */
- (void)onMyHandStateChange {
  if(hasListeners == NO) return;
  [self sendEventWithName:@"any" body:@"onMyHandStateChange"];
}

/*!
 @brief Callback event that the user state is updated in meeting.
 */
- (void)onInMeetingUserUpdated {
  if(hasListeners == NO) return;
  [self sendEventWithName:@"any" body:@"onInMeetingUserUpdated"];
}

/*!
 @brief The function will be invoked once the user joins the meeting.
 @param userID The ID of user who joins the meeting.
 */
- (void)onSinkMeetingUserJoin:(NSUInteger)userID {
  if(hasListeners == NO) return;
  [self sendEventWithName:@"any" body:@"onSinkMeetingUserJoin"];
}

/*!
 @brief The function will be invoked once the user leaves the meeting.
 @param userID The ID of user who leaves the meeting.
 */
- (void)onSinkMeetingUserLeft:(NSUInteger)userID {
  if(hasListeners == NO) return;
  [self sendEventWithName:@"any" body:@"onSinkMeetingUserLeft"];
}

/*!
 @brief The function will be invoked once user raises hand.
 @param userID The ID of user who raises hand.
 */
- (void)onSinkMeetingUserRaiseHand:(NSUInteger)userID {
  if(hasListeners == NO) return;
  [self sendEventWithName:@"any" body:@"onSinkMeetingUserRaiseHand"];
}

/*!
 @brief The function will be invoked once user lowers hand.
 @param userID The ID of user who lowers hand.
 */
- (void)onSinkMeetingUserLowerHand:(NSUInteger)userID {
  if(hasListeners == NO) return;
  [self sendEventWithName:@"any" body:@"onSinkMeetingUserLowerHand"];
}

/*!
 @brief The function will be invoked once user change the screen name.
 @param userID Specify the user ID whose status changes.
 @param userName New screen name displayed.
 */
- (void)onSinkUserNameChanged:(NSUInteger)userID userName:(NSString *_Nonnull)userName {
  if(hasListeners == NO) return;
  [self sendEventWithName:@"any" body:@"onSinkUserNameChanged"];
}

/*!
 @brief Notify user that meeting host changes.
 @param hostId The user ID of host.
 */
- (void)onMeetingHostChange:(NSUInteger)hostId {
  if(hasListeners == NO) return;
  [self sendEventWithName:@"any" body:@"onMeetingHostChange"];
}

/*!
 @brief Callback event that co-host changes.
 @param cohostId The user ID of co-host.
 */
- (void)onMeetingCoHostChange:(NSUInteger)cohostId {
  if(hasListeners == NO) return;
  [self sendEventWithName:@"any" body:@"onMeetingCoHostChange"];
}

/*!
 @brief Callback event that user claims the host.
 */
- (void)onClaimHostResult:(MobileRTCClaimHostError)error {
  if(hasListeners == NO) return;
  [self sendEventWithName:@"any" body:@"onClaimHostResult"];
}

- (NSArray<NSString *> *)supportedEvents {
  return @[@"any"];
}

- (BOOL)dictionary: (NSDictionary *)dict
            hasKey: (NSString *)key {
  if(dict == nil) return NO;
  return dict[key] != nil;
}
@end
