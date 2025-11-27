#import <Cordova/CDV.h>

@interface Dialer : CDVPlugin
- (void)call:(CDVInvokedUrlCommand*)command;
- (void)email:(CDVInvokedUrlCommand*)command;
@end

@implementation Dialer

- (void)call:(CDVInvokedUrlCommand*)command {
    NSString *number = [command.arguments objectAtIndex:0];

    if (!number || [number length] == 0) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No number provided"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    NSString *dial = [@"tel://" stringByAppendingString:number];
    NSURL *url = [NSURL URLWithString:dial];

    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication *app = [UIApplication sharedApplication];

        if ([app canOpenURL:url]) {
            [app openURL:url options:@{} completionHandler:nil];

            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        } else {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot open dialer"];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
    });
}

- (void)email:(CDVInvokedUrlCommand*)command {
    NSString *to = [command.arguments objectAtIndex:0];
    NSString *subject = [command.arguments objectAtIndex:1];
    NSString *body = [command.arguments objectAtIndex:2];

    if (!to || [to length] == 0) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No recipient provided"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    // URL-encode subject and body
    NSCharacterSet *allowed = [NSCharacterSet URLQueryAllowedCharacterSet];

    NSString *encodedSubject = [[subject ?: @"" stringByAddingPercentEncodingWithAllowedCharacters:allowed] ?: @""];
    NSString *encodedBody = [[body ?: @"" stringByAddingPercentEncodingWithAllowedCharacters:allowed] ?: @""];

    NSString *mailtoString = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@",
                              to,
                              encodedSubject,
                              encodedBody];

    NSURL *url = [NSURL URLWithString:mailtoString];

    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication *app = [UIApplication sharedApplication];

        if ([app canOpenURL:url]) {
            [app openURL:url options:@{} completionHandler:nil];

            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        } else {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot open mail app"];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
    });
}

@end
