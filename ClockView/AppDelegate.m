//
//  AppDelegate.m
//  ClockView
//
//  Created by 崔先生的MacBook Pro on 2025/4/29.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    ViewController *vc = [ViewController new];
    self.window.rootViewController = vc;
    return YES;
}

@end
