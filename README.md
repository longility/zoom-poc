# zoom-poc

NEED: We are looking for events to know when the current user joined and when the current user left the meeting.
I think we are needing these events that are in `MobileRTCUserServiceDelegate` that are not triggered: `onSinkMeetingUserJoin`, `onSinkMeetingUserLeft`.

`onInMeetingUserUpdated` event is triggering, which is in the same delegate (i.e. `MobileRTCUserServiceDelegate`) as the events that are not being triggered.

> FYI, sdk key/secret and meetings are redacted
