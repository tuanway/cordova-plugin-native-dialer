#import <Cordova/CDV.h>
#import <UIKit/UIKit.h>

@interface Dialer : CDVPlugin
- (void)call:(CDVInvokedUrlCommand*)command;
- (void)email:(CDVInvokedUrlCommand*)command;
@end

@implementation Dialer

#pragma mark - Public API

- (void)call:(CDVInvokedUrlCommand*)command {
    NSString *number = [command.arguments objectAtIndex:0];

    if (!number || [number length] == 0) {
        CDVPluginResult *result =
            [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                               messageAsString:@"No number provided"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    // tel: URL
    NSString *dialString = [NSString stringWithFormat:@"tel:%@", number];
    NSURL *url = [NSURL URLWithString:dialString];

    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication *app = [UIApplication sharedApplication];

        if ([app canOpenURL:url]) {
            // Use the older API so it compiles fine on all Cordova iOS setups
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [app openURL:url];
#pragma clang diagnostic pop

            CDVPluginResult *result =
                [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        } else {
            CDVPluginResult *result =
                [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                   messageAsString:@"Cannot open dialer"];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
    });
}

- (void)email:(CDVInvokedUrlCommand*)command {
    NSString *to      = [command.arguments objectAtIndex:0];
    NSString *subject = [command.arguments objectAtIndex:1];
    NSString *body    = [command.arguments objectAtIndex:2];

    if (!to || [to length] == 0) {
        CDVPluginResult *result =
            [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                               messageAsString:@"No recipient provided"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    NSString *encodedSubject = [self urlEncode:subject];
    NSString *encodedBody    = [self urlEncode:body];

    NSString *mailtoString = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@",
                              to, encodedSubject, encodedBody];

    NSURL *url = [NSURL URLWithString:mailtoString];

    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication *app = [UIApplication sharedApplication];

        if ([app canOpenURL:url]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [app openURL:url];
#pragma clang diagnostic pop

            CDVPluginResult *result =
                [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        } else {
            CDVPluginResult *result =
                [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                   messageAsString:@"Cannot open mail app"];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
    });
}

#pragma mark - Helpers

- (NSString *)urlEncode:(NSString *)string {
    if (!string || [string length] == 0) {
        return @"";
    }

    // Older but very compatible URL encoder
    CFStringRef originalString = (__bridge CFStringRef)string;
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(
        kCFAllocatorDefault,
        originalString,
        NULL,
        CFSTR("!*'\"();:@&=+$,/?%#[] "),
        kCFStringEncodingUTF8
    );

    NSString *encoded = (__bridge_transfer NSString *)escaped;
    return encoded ?: @"";
}

@end
