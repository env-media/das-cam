---
title: Das Cam Privacy Policy
---

# Das Cam Privacy Policy

Effective date: November 7, 2026

## Who we are

Das Cam is a camera app for iPhone and iPad, made by ENV Media, LLC ("we" or "us").
For any question or request about your data, write to contact@env-media.com.

## In short

- Your recordings stay on your devices and are never uploaded. Das Cam keeps them in its own storage, and they go to
  your Photos library only if you choose to save them there.
- There is no account, no advertising, no advertising identifier and no tracking across other companies' apps or
  websites. We do not sell your data or share it with advertisers.
- Das Cam sends usage analytics to PostHog, stored in the EU. In the European Economic Area, the UK, Switzerland and
  China, no analytics are sent unless you turn them on (how the app tells where you are is explained below).
  Elsewhere, basic usage analytics, including how warm your device runs, are always on, and the optional device
  diagnostics can be turned off.
- A problem report is sent only after you have reviewed it and tapped Send. It goes to Sentry, stored in the EU,
  and we delete it once its problem is fixed, within 90 days at most. No AI tool reads a report from an App Store
  user or an external tester.
- When you pair two devices, they talk to each other directly. Nothing passes through an internet server.

## What Das Cam never collects

- Your videos, audio or photos, or anything the camera sees. The only images we receive are screenshots you choose to
  send us, for example attached to a problem report.
- Your location. Das Cam reads your location only to tag your own clips when you turn that on (see below), and never
  sends it to us. (To apply the right privacy rules, it also looks up which country your internet connection appears
  to be in: see "How Das Cam knows which rules apply".)
- Your name, email address, phone number or contacts. Das Cam has no account. (If you email us, or type these into a
  report, we receive what you wrote.)
- Your device's advertising identifier. Das Cam never asks to track you.
- A recording of your screen. (Touch analytics, below, note where and how the screen was touched, never what it
  showed.)

## What stays on your device

- **Recordings.** Kept in Das Cam's own storage on your device. Das Cam lists them on its recordings screen, where you
  can play, share, delete or save each one to your Photos library. Das Cam asks for permission to add to Photos only
  when you choose to save there; once you allow it, new recordings are saved to Photos automatically, and a recording
  leaves Das Cam's storage once Photos has it. Das Cam reads your Photos library only if you also allow it to show the
  recordings it saved there, and then it reads only those videos, found by the identifiers it kept when saving them.
  It never looks at your other photos or videos. Das Cam's storage is
  included in your device backups and shows in the Files app.
- **Location in your clips.** Off unless you turn it on. If you turn on Settings > Embed location in clips, Das Cam
  asks to use your location while the app is open, and writes where you were into the clips you record, in the same
  form the built-in Camera app uses. Clips also carry the device make and model, the lens and the date. A paired
  Controller can switch this setting on the Recorder, but the Recorder adds location only if location permission was
  already granted on the Recorder itself.
- **Logs and crash reports.** Das Cam's diagnostic logs and the crash and hang reports iOS gives the app stay on your
  device. They leave it only when you choose to send them.
- **Paired devices.** The devices you have paired with (their model, a short code, any name you gave them, and the
  local network address they were last seen at), and the keys that protect each pairing. The keys are kept in the
  iOS Keychain on that device only, and are never synced or backed up.
- **Your trial and subscription status** (which plan you have, and when it started and ends). It is kept in the iOS
  Keychain, so it survives deleting and reinstalling the app, and it is included in encrypted device backups. It is
  not sent to us.

## Usage analytics

### What is sent

Usage analytics show us how the app is used, so that confusing or nonintuitive portions of the user experience can
be found and fixed. Each event records one thing that happened in the app, for example:

- the app was opened;
- a recording started or stopped, and how long it was, as a range such as "under 1 minute";
- a capture format or zoom level was chosen, a screen was opened, or a setting was turned on or off;
- tutorial pages were viewed, and in which of the app's lessons, with the reading time as a range;
- the offer to save recordings to Photos was shown or answered, and whether you then allowed Photos access;
- the upgrade screen was shown, a free trial started, a purchase was completed (with the product) or cancelled, or an
  offer code was redeemed;
- a problem report was opened or sent (with its category);
- how pre-recording started up, with times as ranges;
- outside the EEA, the UK, Switzerland and China: the device's heat level, as described under "Device diagnostics"
  below, where it is part of usage analytics instead.

Every value in an event is a number, a choice from a fixed list the app defines, or a technical label such as the
app's version. There is no free text, so an event cannot carry file names, device names, your location or anything you
recorded.

With each event we receive the time it happened, the app's build number (and, when the app is opened, its version),
whether that copy of the app came from the App Store, TestFlight or a developer build, a random ID for the event
itself (so that an event sent twice is counted once), and a random installation ID that Das Cam creates the first time
it runs. That ID is not your device's advertising identifier or vendor identifier and is not linked to your identity.
Deleting the app deletes it, and a reinstall creates a new one. Every event also carries your device's model, its iOS
version and its heat level at that moment (one of the four levels iOS reports, never a temperature). They are sent
only when the event itself may be sent, and in the EEA, the UK, Switzerland and China the heat level only while
device diagnostics are on (see "Your region decides the defaults"). PostHog builds no profile of you.

### Touch analytics

To find controls that people struggle with, Das Cam also records how the screen was touched, sent in batches of one
event per screen visit or per minute. For each gesture: its kind (tap, double tap, long press, swipe or drag); where
it started, as a percentage across and down the screen; for swipes, drags and long presses, its path, sampled up to 8
times a second for up to 3 seconds; how long the finger stayed down; which of the app's controls responded, or that
none did; and what the app did as a result (for example, started a recording or changed the zoom). Each batch also
notes which of the app's screens was open (for example, the camera or Settings), whether the device was the Recorder
or the Controller, and how it was held, and counts touches that nothing answered. This is a label for the screen, not
a picture of it: Das Cam never takes screenshots or records your screen. Touch analytics never include what the camera
sees, any text you type, or any names.

### Device diagnostics (optional)

A second kind of analytics describes your devices and their surroundings rather than what you did:

- how your devices found each other when pairing or reconnecting (for example Multipeer Connectivity, Bonjour or a
  direct local-network connection), and whether it worked;
- once a day, counts of the ways the app ended in the past day, for example how many times iOS closed it for using too
  much memory, or it crashed. Counts only: no crash report goes with them;
- in the EEA, the UK, Switzerland and China, the device's heat level, each time iOS reports a change (iOS reports
  one of four levels, never a temperature), with what the app was doing then: how long it had been open and how long
  pre-recording had been on, whether a recording was running, the capture format and camera settings, whether the
  device was the Recorder or the Controller and was sending a live preview, and the battery level, charging and Low
  Power Mode; and once per session, how long the device spent at each level, with the capture formats used;
- when capture fails: the camera became unavailable (for example while another app used it), it could
  not be set up, the microphone failed, a finished recording could not be saved to Photos, or a recording's own file
  failed. Each is sent as one label from a fixed list, with nothing about the recording itself.

### Your region decides the defaults

| Where you are | Usage analytics | Device diagnostics |
|---|---|---|
| EEA, UK, Switzerland, China | Off until you turn it on | Off until you turn it on |
| Everywhere else | Always on, from the first launch; no switch | On; you can turn it off |

You make your choice on the first-run screen. In the EEA, the UK, Switzerland and China it asks you one question,
whether to share anonymous usage data, with two buttons of equal weight, Share and Don't share; nothing is chosen for
you, Don't share sends nothing, and device diagnostics are sent only if you also turn on their switch. You can change
your choice later in Das Cam's Settings, in the Privacy
section: "Share anonymous usage data" (shown only where usage analytics need your permission) and "Share device
diagnostics" (shown everywhere). Turning a switch off takes effect at once, and events of that kind that have not been
sent yet are deleted from your device. Without a connection, events wait on your device until they can be sent.

### How Das Cam knows which rules apply

Das Cam does not ask for your location to decide this. It uses three things: the country of your App Store account,
your device's region setting, and the country your internet connection appears to come from. For the last one, when
the app has no answer from the past 30 days, it sends one request to Cloudflare (never over cellular data or in Low
Data Mode). Cloudflare sees your IP address, as with any web request, and replies with a two-letter country code.
The request carries no identifier and no analytics, and the app keeps only the country code, on your device.

If any of these three places you in one of the regions above, you are asked first. If the app later finds that you are
in one of those regions, it stops sending, deletes any events waiting to be sent, and asks you at the next launch.

## Problem reports

You can send us a report from Settings > Report a problem, or when Das Cam offers to after a crash. The report is built
on your device, and nothing is sent until you have been able to read every part of it and have tapped Send. A report
contains:

- what you wrote (required), and the kind of problem you picked;
- a screenshot, only if you choose one. The app never captures your screen by itself;
- Das Cam's diagnostic logs: technical messages about what the app was doing, including actions you took in it, the
  file names the app gave your recordings, and the names and local network addresses of devices you have paired with.
  While building the report, the app replaces the device names it knows with labels such as "peer-1", but some names
  can remain;
- your recent activity in the app: your 500 most recent analytics events, which the app keeps on your device in every
  region, whether or not analytics are on;
- crash and hang reports that iOS gave the app;
- details of the device and the app: the device model, the iOS version, your language and region format, free
  storage, memory, temperature state, when the device last started up, the app's version and build, whether that copy
  came from the App Store, TestFlight or a developer build, your trial or subscription status (for example "trial, 9
  days left"), and the state of any connection to a paired device.

Send uploads the report to Sentry, which stores it for us in its EU data region. The app sends no user ID, name or
email address with it, and tells Sentry not to store your IP address. You can tap "Share instead" to send the file
yourself, for example by email. If Das Cam cannot reach Sentry, it keeps the report and sends it later by itself; until
then the report waits at the top of Report a problem, where you can share or delete it. We use reports only to
diagnose and fix problems, and no AI tool reads a report from an App Store user or an external tester (see "AI tools
and reports").

## Crash information

- A problem report you send can carry the crash and hang reports iOS gave the app (above).
- With device diagnostics on, the app sends the daily counts of how it ended (above).
- If you have turned on Share With App Developers in iOS (Settings > Privacy & Security > Analytics & Improvements),
  Apple shares crash reports and other diagnostics about Das Cam with us, under Apple's privacy policy. If you test a
  beta through TestFlight, crash reports and feedback you send through TestFlight also reach us through Apple.
- Das Cam contains no third-party crash-reporting software.

## AI tools and reports

If you use Das Cam from the App Store, or test it through TestFlight as an external tester, no AI tool reads what you
report to us: your problem reports, your emails, the feedback and crash reports you send through TestFlight, and the
crash reports Apple passes on to us from your device. We read them ourselves, and we never paste them into an AI tool.
The one exception is a crash's stack trace, the list of functions that were running when Das Cam crashed, which an
AI tool may read once everything that identifies a device or a person has been removed.

We use AI tools only with reports from our own test team: the people on our App Store Connect team who test Das Cam's
builds (TestFlight calls them internal testers). The tools help us sort those reports and group the ones that
describe the same bug.

## Your devices' names in iCloud

So that your own devices can show each other by the names you gave them, Das Cam stores each device's name in your
iCloud key-value storage. iCloud syncs it only between devices signed in to your Apple ID, so only your own devices
show these names; anyone else's device sees only the device's model and a short code. These names are never sent to us,
never written to the app's logs, and kept out of problem reports. iCloud is Apple's service, covered by Apple's privacy
policy. (Reading a device's name needs a permission from Apple. Until the app has it, devices are shown by their model
and nothing is stored in iCloud.)

## Pairing two devices

Das Cam can pair two devices so that one (the Controller) can see and control the other (the Recorder).

- The devices find and connect to each other directly, using Apple's Multipeer Connectivity, Bonjour and Network
  framework, over your local network, peer-to-peer Wi-Fi or Bluetooth. That is why Das Cam asks for Local Network and
  Bluetooth permission. Nothing passes through an internet server.
- While Das Cam is looking for a device, or is ready for a device it has already paired with, it announces itself
  to nearby devices. The announcement names the device type with a short code (for example "iPhone-7B91") and
  the hardware model, not the name you gave your device.
- Pairing starts only when one person taps Pair and the other allows it, and both confirm that their devices show the
  same 6-digit code. After that, the two devices prove to each other that they share the pairing key before either
  accepts a command or video, and the commands and video between them are encrypted. How the pairing and its
  encryption work, step by step: <https://env-media.github.io/das-cam/pairing-protocol/>.
- The Controller receives the Recorder's live preview and a small thumbnail of each finished recording, with its length
  and size. The recordings themselves stay on the Recorder.

## Purchases

Das Cam Premium is sold through the App Store as a monthly or yearly auto-renewing subscription, with a free 14-day
trial. Apple handles payment. We never see your name, Apple ID or payment details: the app reads your purchases from
Apple and keeps only their status and dates, on your device (see above). Purchase events are also part of
usage analytics (see above). The Terms of Use are Apple's standard licence agreement:
<https://www.apple.com/legal/internet-services/itunes/dev/stdeula/>.

## Checking for a newer version

When you open Das Cam, at most once an hour, it checks whether a newer version exists. Copies from the App Store read
Apple's public App Store listing for Das Cam; TestFlight beta copies read a small file on GitHub that names the newest
beta. The request carries no identifier. Apple or GitHub sees your IP address, as with any web request.

## Who receives data

| Service | What it receives | Where it is stored | Why |
|---|---|---|---|
| PostHog | Analytics events and the random installation ID. It also sees your IP address when the app uploads; PostHog is set to discard it and to work out no location from it. | EU (Frankfurt, Germany) | Usage analytics |
| Sentry | Problem reports you send. It also sees your IP address when the app uploads; the app tells it not to store it. | EU | Diagnosing problems |
| Cloudflare | The country request, which reveals your IP address. | Under Cloudflare's policy | Choosing the consent rules for your region |
| Apple | Purchases and subscriptions; the update check's request from App Store copies, which reveals your IP address; your devices' names in iCloud; crash reports and TestFlight feedback, if you share them. | Under Apple's policy | Payments, update check, iCloud sync, crash reports |
| GitHub | The update check's request from TestFlight beta copies, which reveals your IP address. | Under GitHub's policy | Telling beta testers a new build exists |
| AI service providers | Reports from our own test team only, when AI tools help us read them. Never a report from an App Store user or an external tester. | Can be outside the EU, for example in the United States | Sorting our test team's reports and grouping the ones about the same bug |

PostHog and Sentry process this data only to provide their service to us, under data processing agreements that
protect it at least as well as this policy does. Apple, Cloudflare and GitHub handle what they receive under their own
privacy policies: <https://www.apple.com/legal/privacy/>, <https://www.cloudflare.com/privacypolicy/>,
<https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement>.
We do not sell your data or share it with advertisers or data brokers.

## Where data is stored

PostHog stores the analytics it receives from Das Cam in its EU cloud, in Frankfurt, Germany. Sentry stores the problem
reports you send in its EU data region. Both providers may also process this data in the United States and in other
countries where their subprocessors work. ENV Media, LLC is based in the United States, where Das Cam is developed, so
we access this data, analytics and problem reports alike, from the United States. When AI tools help us read a report
from our own test team, that report can also be processed outside the EU; a report from an App Store user or an
external tester never goes to an AI tool. Transfers of data from the European Economic Area, the UK and Switzerland
rely on the safeguards in PostHog's and Sentry's data processing agreements: the EU-U.S. Data Privacy Framework (with
its UK Extension and the Swiss-U.S. Data Privacy Framework) and the European Commission's Standard Contractual
Clauses, with the UK's addendum and the adjustments for Switzerland.

## How long data is kept

- Usage analytics at PostHog: one year, the retention period of our PostHog plan.
- Problem reports: we delete each report from Sentry, along with any copy we downloaded to work on it, once the
  problem it describes is fixed, and never more than 90 days after it reaches us. Sentry also deletes a report's file,
  with its logs and any screenshot, after 30 days, the retention period of our Sentry plan, and it deletes its own
  backups 90 days after making them. A report from our own test team that an AI tool helped us read can also stay in
  that tool's records, under its provider's terms.
- On your device: analytics events until they are sent, or until you turn their switch off; the activity list keeps
  your 500 most recent events; crash and hang reports, the 6 most recent, until a report carrying them has been sent;
  logs the app saves itself, 7 days at most. Deleting the app removes all of these and the installation ID. iOS keeps
  Keychain items after an app is deleted, so your subscription status and pairing keys stay on the device.
- Recordings in Das Cam's own storage: until you delete them or save them to your Photos library. Deleting the app
  deletes the recordings in its storage; those you saved to Photos stay there.
- Cloudflare, Apple and GitHub keep what they receive according to their own policies.

## Your choices and rights

- **Analytics switches:** Settings > Privacy (see "Your region decides the defaults").
- **Location in clips:** Settings > Embed location in clips, or iOS Settings > Privacy & Security > Location Services >
  Das Cam.
- **Problem reports** are sent only when you tap Send. A report waiting to be sent can be deleted at the top of
  Report a problem.
- **Deleting Das Cam** stops all collection.
- **Requests:** write to contact@env-media.com to ask for a copy of your data, to correct or delete it, to object to
  how it is used, or to withdraw your consent. Analytics are tied only to a random installation ID that the app does
  not show you, so we cannot tell which records are yours, and usually cannot find them on request. Turning the switch
  off, where there is one, or deleting the app stops further collection. For a problem report, tell us roughly when
  you sent it and what it said, and we will find it and delete it.
- If you are in the EEA, the UK or Switzerland, you can also complain to your data protection authority.

## Legal bases (EEA, UK and Switzerland)

- Usage analytics and device diagnostics: your consent, which you can withdraw at any time in Settings > Privacy.
- Problem reports: your request that we look into a problem.
- The country request to Cloudflare: our legitimate interest in showing each person the privacy choices that apply
  where they are. Consent cannot come first, because this check is what decides which consent rules apply. The app
  keeps only the country code, on your device, and uses it only for this.
- The update check: our legitimate interest in telling you that a newer version of the app exists.
- You can object to these two checks (see Requests above).

## Children

Das Cam is not directed at children under 13, and we do not knowingly collect personal information from children. If
you think a child has sent us a problem report, contact us and we will delete it.

## Changes to this policy

We will post any change to this policy on this page, with a new effective date. A change that adds new collection
usually belongs to a feature you choose to turn on, and the app explains that feature where you find it, especially
in Settings.

## Contact

ENV Media, LLC, contact@env-media.com
