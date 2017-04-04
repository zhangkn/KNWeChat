//
//  AppDelegate.h
//  KNWeChat
//
//  Created by devzkn on 04/04/2017.
//  Copyright © 2017 hisun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    XMPPResultTypeLoginSuccess,//登录成功
    XMPPResultTypeLoginFailure,//登录失败
    XMPPResultTypeNetErr//网络不给力
}XMPPResultType;

typedef void (^XMPPResultBlock)(XMPPResultType type);// XMPP请求结果的block

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


/**
 *  用户登录
 */
-(void)xmppUserLogin;
-(void)logout;
/**
 *  用户登录
 */
-(void)xmppUserLogin:(XMPPResultBlock)resultBlock;

@end

