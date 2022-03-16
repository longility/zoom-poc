//
//  RCTZoomMeeting.h
//  ZoomPoc
//
//  Created by Long Mai on 2/7/22.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <MobileRTC/MobileRTC.h>

@interface RCTZoomMeeting : RCTEventEmitter <RCTBridgeModule, MobileRTCAuthDelegate, MobileRTCUserServiceDelegate>

@end
