# cordova-plugin-native-dialer

Simple Cordova plugin to open the native phone dialer and email composer (iOS & Android).

## Install

```bash
cordova plugin add ./cordova-plugin-native-dialer
```

## Usage

```js
// Call
NativeDialer.call("12345678",
  () => console.log("Dialer opened"),
  (err) => console.error("Call error:", err)
);

// Email
NativeDialer.email(
  "hello@example.com",
  "Test Subject",
  "Body text here...",
  () => console.log("Email composer opened"),
  (err) => console.error("Email error:", err)
);
```
