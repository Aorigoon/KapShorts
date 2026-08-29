# Deferred Export Delivery — Research Notes

## Official findings

Google Play Feature Delivery lets an Android App Bundle separate an optional feature from the base installation and download that feature on demand. Native code can be loaded from an on-demand module. A request that needs to be immediately available must be started while the application is in the foreground; deferred background delivery is best effort and does not expose download progress. The feature must handle install errors such as network, storage, unavailable module, and missing Play Store conditions. [1]

Flutter supports deferred components on Android through Android dynamic feature modules. The approach requires deferred Dart imports, a release/profile build, and a single Android App Bundle uploaded to Google Play. Flutter's documentation explains that debug mode treats deferred imports as ordinary imports. The Android base application must be configured for Play Store split delivery, and the `flutter build appbundle` deferred-components validator generates and checks module setup files. [2]

## Implications for SubReel

The large FFmpeg native libraries may be a candidate for a dedicated export module, but the current `ffmpeg_kit_flutter_new` Flutter plugin must be refactored or wrapped so it is only referenced after the Play-delivered module is installed. This is feasible but not a quick packaging toggle. It requires a Google Play AAB distribution path and an internal/closed Play test to validate first-export download, errors, and native library loading. It cannot provide the same automatic post-install download for a sideloaded standalone APK.

## Sources

[1] https://developer.android.com/guide/playcore/feature-delivery/on-demand

[2] https://docs.flutter.dev/perf/deferred-components
