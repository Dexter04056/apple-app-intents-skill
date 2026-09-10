# Onscreen context, transfer, and donations

## Match the annotation to the interface

| Interface | Starting point |
|---|---|
| One primary document/activity | `NSUserActivity` associated with the entity |
| A few visible records | View-level entity identifiers |
| Large lists and selection | Current collection annotation API; resolve selected item IDs lazily |
| Custom canvas/layer rendering | `AppEntityUIElement` geometry and selection provider |
| Notification, alarm, or Now Playing | Framework-supported persistent entity annotation |

Use the current [contextual cues guide](https://developer.apple.com/documentation/appintents/providing-contextual-cues-to-apple-intelligence-and-siri) for exact API names. Older examples may use `.appEntity(...)`; current SDK guidance includes `.appEntityIdentifier(...)`. Verify symbol availability before choosing. Do not add protocol conformance to a system type and assume it gains a system integration.

Associate the same persistent identifier that queries can resolve. Test “this one,” multiple visible records, selected records scrolled out of view, a detail screen, and a removed record. Avoid annotating an entire screen with the first list element. For UIKit/AppKit, use the corresponding responder or collection interfaces rather than forcing a SwiftUI wrapper.

## Transfer real meaning

Use [CoreTransferable](https://developer.apple.com/documentation/coretransferable) for appropriate file/data representations. Where supported, [IntentValueRepresentation](https://developer.apple.com/documentation/appintents/intentvaluerepresentation) can preserve a system-understood person, name, or location instead of reducing everything to text or an image.

Separate resolving an incoming value to an existing record (`IntentValueQuery`) from importing a genuinely new record. Prevent a “find this contact” operation from silently creating duplicate contacts. Validate imported data and access rights; a foreign identifier is not automatically one of the app's database keys.

Only export the representation the person intended to share. Handle missing attachments, access revocation, large files, and unsupported content. Cross-app compatibility depends on both participating apps and the selected representation. Test the destination rather than assuming conformance proves interoperability.

## Donate actual UI interactions

[IntentDonationManager](https://developer.apple.com/documentation/appintents/intentdonationmanager) supplies an interaction-donation interface. Donations should describe completed real UI actions with the correct parameters/results. Avoid donating failed attempts, speculative behavior, or every render. Prevent duplicate donation when the same service is called by an intent the system already observes.

The [WWDC26 advanced session](https://developer.apple.com/videos/play/wwdc2026/343/) explains donations for preferences/ongoing activities and annotations for notifications, playback, and alarms. Adoption should follow the app's actual features; do not add those frameworks only to check a box.
