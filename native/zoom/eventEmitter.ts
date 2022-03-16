import {NativeEventEmitter} from 'react-native';

import {getNativeZoom} from './module';

// should not create and store as const in order to handle compatibility issues properly
export const createNativeZoomEventEmitter = ():
  | NativeEventEmitter
  | undefined => {
  const nativeModule = getNativeZoom();

  return nativeModule ? new NativeEventEmitter(nativeModule) : undefined;
};
