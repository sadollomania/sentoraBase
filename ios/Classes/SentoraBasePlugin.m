#import "SentoraBasePlugin.h"
#import <sentora_base/sentora_base-Swift.h>

@implementation SentoraBasePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSentoraBasePlugin registerWithRegistrar:registrar];
}
@end
