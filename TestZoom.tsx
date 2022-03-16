import React, {useEffect} from 'react';
import {Button, View} from 'react-native';

import {createNativeZoomEventEmitter, getNativeZoom} from './native/zoom';

const nativeZoomEventEmitter = createNativeZoomEventEmitter();
const TestZoom = () => {
  const initZoom = async () => {
    const result = await getNativeZoom()?.initialize({
      domain: 'zoom.us',
      sdkKey: 'REDACTED',
      sdkSecret: 'REDACTED',
    }); // TODO: HARDCODED FOR TESTING
    console.log({result});
  };
  useEffect(() => {
    initZoom();
    const subscription = nativeZoomEventEmitter?.addListener('any', event => {
      console.log(`NATIVE_ZOOM_EVENT_EMITTED: ${event}`);
    });
    return () => {
      if (subscription) {
        nativeZoomEventEmitter?.removeSubscription(subscription);
      }
    };
  }, []);

  const handleJoinZoomPress = async () => {
    await getNativeZoom()?.joinMeeting({
      participantName: 'zoom-poc',
      meetingID: 'REDACTED',
      passcode: 'REDACTED',
    });
  };

  return (
    <View>
      <Button title="join zoom" onPress={handleJoinZoomPress} />
    </View>
  );
};

export default TestZoom;
