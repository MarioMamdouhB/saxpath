# Implementation Plan - Reliability and Stability Improvements

This plan addresses the bugs and recommendations identified during the project review, focusing on network reliability and fixing the white screen issue in the web application.

## User Review Required

> [!NOTE]
> The retry mechanism will attempt to connect to the server up to 3 times before showing an error. This might slightly increase the initial loading time if the server is actually down.

## Proposed Changes

### Mobile App (`apps/mobile`)

#### [SaxPathApiClient](file:///C:/Users/Dell/Desktop/sax path/saxpath/apps/mobile/lib/data/saxpath_api_client.dart)
- Add a retry loop to `_withTimeout` to handle transient network failures automatically for all API requests.

#### [app.dart](file:///C:/Users/Dell/Desktop/sax path/saxpath/apps/mobile/lib/app.dart)
- Modify `_syncProgressFromServer` to use the improved client and handle cases where all retries fail by allowing the user to continue with local data.
- Update `_AppBootSplash` to show a "Retry" button if the server sync fails, instead of just a loading indicator.

#### [dev_stack.ps1](file:///C:/Users/Dell/Desktop/sax path/saxpath/tools/dev_stack.ps1)
- Set the `FLUTTER_WEB_RENDERER` environment variable or find the correct flag for the current Flutter version to ensure the HTML renderer is used, preventing white screens.

## Verification Plan

### Automated Tests
- I will run the existing tests for the API client to ensure the retry logic doesn't break existing functionality.
- `flutter test` in `apps/mobile`.

### Manual Verification
- **Simulate Network Failure:** I will temporarily point the `API_BASE_URL` to a non-existent address and verify that the app attempts retries and then shows the "Retry" button.
- **Web Verification:** I will launch the web app and verify that the white screen no longer appears (checking the browser console for any renderer-related errors).
