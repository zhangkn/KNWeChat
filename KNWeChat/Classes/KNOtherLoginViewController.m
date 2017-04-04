//
//  KNOtherLoginViewController.m
//  KNWeChat
//
//  Created by devzkn on 04/04/2017.
//  Copyright © 2017 hisun. All rights reserved.
//

#import "KNOtherLoginViewController.h"
#import "UIImage+WF.h"
#import "UIButton+WF.h"
#import "MBProgressHUD+HM.h"
#import "AppDelegate.h"

@interface KNOtherLoginViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstraint;
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;


@end

@implementation KNOtherLoginViewController



-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"其它方式登录";
    
    // 判断当前设备的类型 改变左右两边约束的距离
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        self.leftConstraint.constant = 10;
        self.rightConstraint.constant = 10;
    }
    
    // 设置TextFeild的背景
    self.userField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    self.pwdField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    
    [self.loginBtn setResizeN_BG:@"fts_green_btn" H_BG:@"fts_green_btn_HL"];
    
    
    
}
- (IBAction)loginBtnClick {
    // 登录
    
    /*
     * 官方的登录实现
     
     * 1.把用户名和密码放在沙盒
     
     
     * 2.调用 AppDelegate的一个login 连接服务并登录
     */
    
    NSString *user = self.userField.text;
    NSString *pwd = self.pwdField.text;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:user forKey:@"user"];
    [defaults setObject:pwd forKey:@"pwd"];
    [defaults synchronize];// 下次可以自动登陆，或者方便以后的存取
    
    
    //隐藏键盘
    [self.view endEditing:YES];
    
    // 登录之前给个提示
    
    [MBProgressHUD showMessage:@"正在登录中..." toView:self.view];
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    
    __weak typeof(self) selfVc = self;
    
    [app xmppUserLogin:^(XMPPResultType type) {
        [selfVc handleResultType:type];
    }];
}

-(void)handleResultType:(XMPPResultType)type{
    // 主线程刷新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view
         ];
        switch (type) {
            case XMPPResultTypeLoginSuccess:
                NSLog(@"登录成功");
                [self enterMainPage];
                break;
            case XMPPResultTypeLoginFailure:
                NSLog(@"登录失败");
                [MBProgressHUD showError:@"用户名或者密码不正确" toView:self.view];
                break;
            case XMPPResultTypeNetErr:
                [MBProgressHUD showError:@"网络不给力" toView:self.view];
            default:
                break;
        }
    });
    
}


-(void)enterMainPage{
    // 隐藏模态窗口
    [self dismissViewControllerAnimated:NO completion:nil];//退出
    
    // 登录成功来到主界面
    // 此方法是在子线程补调用，所以在主线程刷新UI
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.view.window.rootViewController = storyboard.instantiateInitialViewController;//切换控制器
}


- (IBAction)cancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
