//
//  RCTEZUIKitManage.m
//  RCTEZUIKit
//
//  Created by 左建军 on 2018/3/23.
//  Copyright © 2018年 tuofeng. All rights reserved.
//

#import "RCTEZUIKitManage.h"
#import "EZUIKitViewController.h"
#import "EZUIKitPlaybackViewController.h"

@implementation RCTEZUIKitManage

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(setAppKey:(NSString *)appKey
                  andAccessToken:(NSString *)accessToken
                  andEzopenUrl:(NSString *)ezopenUrl
                  callback:(RCTResponseSenderBlock)callback) {
    UIViewController *controller = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    
    EZUIKitViewController *vc = [[EZUIKitViewController alloc] init];
    vc.appKey = appKey;
    vc.accessToken = accessToken;
    vc.urlStr = ezopenUrl;
    
    //    EZUIKitPlaybackViewController *vc = [[EZUIKitPlaybackViewController alloc] init];
    //    vc.appKey = appKey;
    //    vc.accessToken = accessToken;
    //    vc.urlStr = ezopenUrl;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //      UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [controller presentViewController:vc animated:YES completion:^{
        }];
    });
}

@end
