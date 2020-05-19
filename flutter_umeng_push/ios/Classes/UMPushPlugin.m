#import "UMPushPlugin.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif


#import <UMCommon/UMCommon.h>
#import <UMPush/UMessage.h>

#ifdef DEBUG
#import <UMCommonLog/UMCommonLogHeaders.h>
#endif


#ifdef DEBUG
#define TmLog(fmt, ...) NSLog((@"| UMengPlugin | Flutter | iOS | %s [Line %d]" fmt), __FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define TmLog(fmt, ...)
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

@interface UMPushPlugin()<UNUserNotificationCenterDelegate>

@property (nonatomic, strong) FlutterMethodChannel *channel;
@property (nonatomic, strong) NSDictionary *launchOptions;
@property (nonatomic, strong) UMessageRegisterEntity *entity;
@property (nonatomic, assign) NSInteger notificationTypes;

@end

#else

@interface UMPushPlugin()

@property (nonatomic, strong) FlutterMethodChannel *channel;
@property (nonatomic, strong) NSDictionary *launchOptions;
@property (nonatomic, strong) UMessageRegisterEntity *entity;
@property (nonatomic, assign) NSInteger notificationTypes;

@end

#endif



@implementation UMPushPlugin

static NSString * const kMethod_setup = @"setup";
static NSString * const kMethod_applyForPushAuthorization = @"applyForPushAuthorization";

// MARK: - 生命周期函数
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static UMPushPlugin *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
        instance.entity = [[UMessageRegisterEntity alloc] init];
        instance.entity.types = UMessageAuthorizationOptionNone;
        
        instance.notificationTypes = UMessageAuthorizationOptionNone;
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// MARK: - 插件相关
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"umpush"
            binaryMessenger:[registrar messenger]];
    UMPushPlugin* instance = [UMPushPlugin sharedInstance];
    instance.channel = channel;
    
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }
    if ([kMethod_setup isEqualToString:call.method]) {
        [self setup:call result: result];
    } else if ([kMethod_applyForPushAuthorization isEqualToString:call.method]) {
        [self applyForPushAuthorization:call result:result];
    } else if ([@"" isEqualToString:call.method]) {
        
    } else {
        result(FlutterMethodNotImplemented);
    }
}

// MARK: - Plugin Method
- (void)setup:(FlutterMethodCall*)call result:(FlutterResult)result {
    TmLog(@"");
    NSDictionary *arguments = call.arguments;
    
    NSNumber *enabledLog = arguments[@"enabledLog"];
    
    // 开发者需要显式的调用此函数，日志系统才能工作
    [UMCommonLogManager setUpUMCommonLogManager];
    if ([enabledLog boolValue]) {
        [UMConfigure setLogEnabled:true];
    } else {
        [UMConfigure setLogEnabled:false];
    }
    
    NSString *appKey = arguments[@"appKey"];
    NSString *channel = arguments[@"channel"];
    
    [UMConfigure initWithAppkey:appKey channel:channel];
}

- (void)applyForPushAuthorization:(FlutterMethodCall*)call result:(FlutterResult)result {
    TmLog(@"");
    NSInteger notificationTypes = [call.arguments integerValue];
    self.entity.types = notificationTypes;
    self.notificationTypes = notificationTypes;
    [UMessage registerForRemoteNotificationsWithLaunchOptions:self.launchOptions Entity:self.entity completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            TmLog(@"通知已经授权");
        } else {
            if (error != nil) {
                TmLog(@"error: %@", error);
            } else {
                TmLog(@"");
            }
        }
    }];
}

// MARK: - FlutterApplicationLifeCycleDelegate
- (BOOL)application:(UIApplication*)application
    didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    
    self.launchOptions = launchOptions;
    
    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    }
    
    return true;
}

//- (BOOL)application:(UIApplication*)application
//willFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
//    return true;
//}

- (void)applicationDidBecomeActive:(UIApplication*)application {
    // 清空角标
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillResignActive:(UIApplication*)application {
    // Do Nothing.
}

- (void)applicationDidEnterBackground:(UIApplication*)application {
    // Do Nothing.
}

- (void)applicationWillEnterForeground:(UIApplication*)application {
    // Do Nothing.
}

- (void)applicationWillTerminate:(UIApplication*)application {
    // Do Nothing.
}

- (void)application:(UIApplication*)application
    didRegisterUserNotificationSettings:(UIUserNotificationSettings*)notificationSettings
    API_DEPRECATED(
        "See -[UIApplicationDelegate application:didRegisterUserNotificationSettings:] deprecation   Use UserNotifications Framework's -[UNUserNotificationCenter requestAuthorizationWithOptions:completionHandler:]",
                   ios(8.0, 10.0)) {
    // TODO:
}

- (void)application:(UIApplication*)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    // TODO: 注册deviceToken
}

- (BOOL)application:(UIApplication*)application
    didReceiveRemoteNotification:(NSDictionary*)userInfo
          fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    // TODO:
//    [UMessage setBadgeClear:true];
    // 防止两次调用completionHandler引起崩溃
    if(![userInfo valueForKeyPath:@"aps.recall"])
    {
        completionHandler(UIBackgroundFetchResultNewData);
    }
    return true;
}

//- (void)application:(UIApplication*)application
//    didReceiveLocalNotification:(UILocalNotification*)notification
//    API_DEPRECATED(
//        "See -[UIApplicationDelegate application:didReceiveLocalNotification:] deprecation    Use UserNotifications Framework's -[UNUserNotificationCenterDelegate willPresentNotification:withCompletionHandler:] or -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]",
//                   ios(4.0, 10.0)) {
//
//}
//
//- (BOOL)application:(UIApplication*)application
//            openURL:(NSURL*)url
//            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id>*)options {
//    return true;
//}
//
//- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url {
//    return true;
//}
//
//- (BOOL)application:(UIApplication*)application
//              openURL:(NSURL*)url
//    sourceApplication:(NSString*)sourceApplication
//         annotation:(id)annotation {
//    return true;
//}
//
//- (BOOL)application:(UIApplication*)application
//    performActionForShortcutItem:(UIApplicationShortcutItem*)shortcutItem
//               completionHandler:(void (^)(BOOL succeeded))completionHandler API_AVAILABLE(ios(9.0)) {
//    return true;
//}
//
//- (BOOL)application:(UIApplication*)application
//    handleEventsForBackgroundURLSession:(nonnull NSString*)identifier
//                      completionHandler:(nonnull void (^)(void))completionHandler {
//    return true;
//}
//
//
//- (BOOL)application:(UIApplication*)application
//    performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
//    return true;
//}
//
//- (BOOL)application:(UIApplication*)application
//    continueUserActivity:(NSUserActivity*)userActivity
//      restorationHandler:(void (^)(NSArray*))restorationHandler {
//    return true;
//}

// MARK: - UNUserNotificationCenterDelegate
// iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0)) {
    // TODO:
    NSDictionary * userInfo = notification.request.content.userInfo;
    //防止两次调用completionHandler引起崩溃
    if(![userInfo valueForKeyPath:@"aps.recall"])
    {
        completionHandler(self.notificationTypes);
    }
}
@end
