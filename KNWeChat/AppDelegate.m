//
//  AppDelegate.m
//  KNWeChat
//
//  Created by devzkn on 04/04/2017.
//  Copyright © 2017 hisun. All rights reserved.
//

#import "AppDelegate.h"
#import "XMPPFramework.h"

@interface AppDelegate ()<XMPPStreamDelegate>{
    XMPPStream *_xmppStream;
    XMPPResultBlock _resultBlock;

}


// 1. 初始化XMPPStream
-(void)setupXMPPStream;


// 2.连接到服务器
-(void)connectToHost;

// 3.连接到服务成功后，再发送密码授权
-(void)sendPwdToHost;


// 4.授权成功后，发送"在线" 消息
-(void)sendOnlineToHost;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}





#pragma mark  -私有方法
#pragma mark 初始化XMPPStream
-(void)setupXMPPStream{
    
    _xmppStream = [[XMPPStream alloc] init];
    
    // 设置代理
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}


#pragma mark 连接到服务成功后，再发送密码授权
-(void)sendPwdToHost{
    NSLog(@"再发送密码授权");
    NSError *err = nil;
    
    // 从沙盒里获取密码
    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"pwd"];
    
    [_xmppStream authenticateWithPassword:pwd error:&err];//登陆
    if (err) {
        NSLog(@"%@",err);
    }
}
#pragma mark  授权成功后，发送"在线" 消息
-(void)sendOnlineToHost{
    
    NSLog(@"发送 在线 消息");
    XMPPPresence *presence = [XMPPPresence presence];
    NSLog(@"%@",presence);
    
    [_xmppStream sendElement:presence];
    
    
}

#pragma mark 连接到服务器
-(void)connectToHost{
    NSLog(@"开始连接到服务器");
    if (!_xmppStream) {
        [self setupXMPPStream];
    }
    
    
    // 设置登录用户JID
    //resource 标识用户登录的客户端 iphone android
    
    // 从沙盒获取用户名
    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    
    XMPPJID *myJID = [XMPPJID jidWithUser:user domain:@"localhost" resource:@"iphone" ];
    _xmppStream.myJID = myJID;
    
    // 设置服务器域名
    _xmppStream.hostName = @"127.0.0.1";//不仅可以是域名，还可是IP地址
    
    // 设置端口 如果服务器端口是5222，可以省略
    _xmppStream.hostPort = 5222;//The default port is 5222.
    
    // 连接
    NSError *err = nil;
    if(![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&err]){
        NSLog(@"%@",err);
    }
    
}


#pragma mark -公共方法
-(void)logout{
    // 1." 发送 "离线" 消息"
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
    
    // 2. 与服务器断开连接
    [_xmppStream disconnect];
    //回到登陆界面
    // 3. 回到登录界面
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    
    self.window.rootViewController = storyboard.instantiateInitialViewController;
    
}



/**
 *  用户登录
 */
-(void)xmppUserLogin{
    
    // 连接主机 成功后发送密码
    [self connectToHost];
    
}


#pragma mark -XMPPStream的代理
#pragma mark 与主机连接成功
-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@"与主机连接成功");
    
    // 主机连接成功后，发送密码进行授权
    [self sendPwdToHost];
}
#pragma mark  与主机断开连接
-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    // 如果有错误，代表连接失败
    NSLog(@"与主机断开连接 %@",error);
    
    
    if(error && _resultBlock){
        _resultBlock(XMPPResultTypeNetErr);
    }
    NSLog(@"与主机断开连接 %@",error);
    
}


#pragma mark 授权成功
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"授权成功");
    
    [self sendOnlineToHost];//告知服务器，本账号在线
    
    // 登录成功来到主界面
    // 此方法是在子线程补调用，所以在主线程刷新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = storyboard.instantiateInitialViewController;//切换根控制器
    });
    
    
    // 回调控制器登录成功
    if(_resultBlock){
        _resultBlock(XMPPResultTypeLoginSuccess);
    }

    
}

/**
 *  用户登录
 */
-(void)xmppUserLogin:(XMPPResultBlock)resultBlock{
    
    // 先把block存起来
    _resultBlock = resultBlock;
    
    //    Domain=XMPPStreamErrorDomain Code=1 "Attempting to connect while already connected or connecting." UserInfo=0x7fd86bf06700 {NSLocalizedDescription=Attempting to connect while already connected or connecting.}
    // 如果以前连接过服务，要断开
    [_xmppStream disconnect];
    
    // 连接主机 成功后发送密码
    [self connectToHost];
    
}

#pragma mark 授权失败
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    NSLog(@"授权失败 %@",error);
    
    
    // 判断block有无值，再回调给登录控制器
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginFailure);
    }
}





@end
