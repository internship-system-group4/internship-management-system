# Zoom meetings

The Meetings pages create a real scheduled Zoom meeting, store Zoom's `join_url` in Firebase, and show a Join button to the creator and selected participants. The participant picker controls visibility inside UIMS; it does not send email invitations.

## One-time setup

1. In the Zoom App Marketplace, create and activate a **Server-to-Server OAuth** app. Add the `meeting:write:meeting:admin` scope.
2. Copy `App_Secrets.config.example` to the ignored `App_Secrets.config`. Fill in `Zoom.AccountId`, `Zoom.ClientId`, `Zoom.ClientSecret`, and `Zoom.HostEmail`. The host email must belong to a Zoom user on the same account who can schedule meetings.
3. On the host Zoom account, allow **Join Before Host** and ensure **Waiting Room** is not locked on. The app requests these settings per meeting and generates a passcode. Zoom account or group locks can override the request.
4. Sign in to UIMS, open **Meetings**, choose **Schedule meeting**, select participants, and create it. The Join button appears on **My meetings** for each selected participant.

The Zoom client secret stays server-side. Never add credentials to `Web.config` or commit `App_Secrets.config`.

If a Zoom meeting is created but Firebase saving fails, contact the administrator before retrying; another attempt would create a second Zoom meeting.
