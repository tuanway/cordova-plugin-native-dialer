package com.example.dialer;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;

import android.content.Intent;
import android.net.Uri;

public class Dialer extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        if ("call".equals(action)) {
            String number = args.getString(0);
            this.callNumber(number, callbackContext);
            return true;
        } else if ("email".equals(action)) {
            String to = args.getString(0);
            String subject = args.getString(1);
            String body = args.getString(2);
            this.sendEmail(to, subject, body, callbackContext);
            return true;
        }

        return false;
    }

    private void callNumber(String number, CallbackContext callbackContext) {
        if (number == null || number.length() == 0) {
            callbackContext.error("No number provided");
            return;
        }

        Intent intent = new Intent(Intent.ACTION_DIAL);
        intent.setData(Uri.parse("tel:" + number));
        cordova.getActivity().startActivity(intent);

        callbackContext.success();
    }

    private void sendEmail(String to, String subject, String body, CallbackContext callbackContext) {
        if (to == null || to.length() == 0) {
            callbackContext.error("No recipient provided");
            return;
        }

        Intent intent = new Intent(Intent.ACTION_SENDTO);
        intent.setData(Uri.parse("mailto:" + Uri.encode(to)));

        if (subject != null) {
            intent.putExtra(Intent.EXTRA_SUBJECT, subject);
        }
        if (body != null) {
            intent.putExtra(Intent.EXTRA_TEXT, body);
        }

        if (intent.resolveActivity(cordova.getActivity().getPackageManager()) != null) {
            cordova.getActivity().startActivity(intent);
            callbackContext.success();
        } else {
            callbackContext.error("No email app available");
        }
    }
}
