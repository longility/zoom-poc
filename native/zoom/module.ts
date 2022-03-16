import type {NativeModule} from 'react-native';
import {NativeModules} from 'react-native';

export enum NativeZoomLocale {
  Default = 0,
  CN = 1,
}
export type NativeZoomInitializeSettings = {
  domain?: string;
  enableLog?: boolean;
  jwtToken?: string;
  locale?: NativeZoomLocale;
  sdkKey?: string;
  sdkSecret?: string;
};

export type NativeZoomJoinMeetingSettings = {
  participantName?: string;
  meetingID?: string;
  passcode?: string;
  noAudio?: boolean;
  noVideo?: boolean;
};

export type NativeZoom = {
  connectAudio: () => Promise<void>;
  initialize: (settings?: NativeZoomInitializeSettings) => Promise<void>;
  isInitialized: () => Promise<boolean>;
  joinMeeting: (settings?: NativeZoomJoinMeetingSettings) => Promise<void>;
} & NativeModule;

// lazily get native module so that tests are less complicated
export const getNativeZoom = (): NativeZoom | undefined => {
  return NativeModules.ZoomMeeting;
};
