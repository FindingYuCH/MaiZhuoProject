//
//  ViewController.m
//  maizhou
//
//  Created by m3 on 15/09/2016.
//  Copyright © 2016 m3. All rights reserved.
//

#import "ViewController.h"
//shareSDK(第三方登录,分享)头文件
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

#import <ShareSDKUI/ShareSDK+SSUI.h>
//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

//新浪微博SDK头文件
#import "WeiboSDK.h"

#import "AFNetworking.h"

@interface ViewController (){
    NSString * fromSource;
}


@end

@implementation ViewController
UIActivityIndicatorView *activityIndicator;
//UIActivityIndicatorView *indicator;

@synthesize webView;

- (void)viewDidLoad {
    [super viewDidLoad];
    //创建webView
    webView = [[UIWebView alloc] init];
    [webView setFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-20)];
    webView.backgroundColor = [UIColor clearColor];
    webView.delegate = self;
    //创建indicatorView
    activityIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.color=[UIColor blackColor];
    //Put the indicator on the center of the webview
    [activityIndicator setCenter:self.view.center];
    
    //Add the indicator to the webView to make it visible
    [webView addSubview:activityIndicator];
    [webView setScalesPageToFit:YES];
    webView.scrollView.bounces = NO;
    //执行indicatorView
    [activityIndicator startAnimating];
    //http://test.mzys365.com/index.php?route=account/login 登录接口 测试
    //首页接口地址
    NSString *urlString = @"http://ys.mzys365.com/index.php";
    //NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //特殊字符编码
    NSString * encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:encodedString]]];
    [self.view addSubview:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)awebView
{
    //NSLog(@"webViewDidFinishLoad");
    [activityIndicator stopAnimating];
    //webView =nil;
    
    
}

#pragma  mark ====webView的代理方法

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString * urlPath = request.URL.absoluteString;
        NSLog(@"url===%@",urlPath);
//    NSString * path = [urlPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    if ([urlPath isEqualToString: @"login://weixin/"]) {
        NSLog(@"微信");
        if([ShareSDK hasAuthorized: SSDKPlatformTypeWechat]){
            //测试,如果已经授权,则 取消授权
            [ShareSDK cancelAuthorize:SSDKPlatformTypeWechat];
        }
        [self otherLoginWeixin];
    }
    if ([urlPath isEqualToString: @"login://QQ/"]) {
        NSLog(@"QQ");
        if([ShareSDK hasAuthorized: SSDKPlatformTypeQQ]){
            //测试,如果已经授权,则 取消授权
            [ShareSDK cancelAuthorize:SSDKPlatformTypeQQ];
        }
        [self otherLoginQQ
         ];
    }
    if ([urlPath isEqualToString: @"login://weibo/"]) {
        NSLog(@"微博");
        if([ShareSDK hasAuthorized: SSDKPlatformTypeSinaWeibo]){
            //测试,如果已经授权,则 取消授权
            [ShareSDK cancelAuthorize:SSDKPlatformTypeSinaWeibo];
        }
        [self otherLoginWeibo];
    }
    if ([urlPath hasPrefix: @"share:"]) {
        
        [self toShare];
    }
    
  

    return YES;
}

#pragma mark=== 分享

- (void)toShare
{
    NSLog(@"分享");
    //1、创建分享参数
    NSArray* imageArray = @[[UIImage imageNamed:@"a.png"]];
//    图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]
    if (imageArray) {
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:@"分享内容"
                                         images:nil //是否要分享 imageArray
                                            url:[NSURL URLWithString:@"http://mob.com"]
                                          title:@"分享标题"
                                           type:SSDKContentTypeAuto];
        //2、分享（可以弹出我们的分享菜单和编辑界面）
        
        [ShareSDK showShareActionSheet:nil
                                 items:nil
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       switch (state) {
                           case SSDKResponseStateSuccess:
                           {
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                   message:nil
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"确定"
                                                                         otherButtonTitles:nil];
                               [alertView show];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:[NSString stringWithFormat:@"%@",error]
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           default:
                               break;
                       }
                   }
         ];}
}

#pragma mark=== QQ的登录
- (void) otherLoginQQ{
    
    [ShareSDK getUserInfo:SSDKPlatformTypeQQ
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess)
         {
             
             NSLog(@"uid=%@",user.uid);
             NSLog(@"%@",user.credential);
             NSLog(@"token=%@",user.credential.token);
             NSLog(@"nickname=%@",user.nickname);
             fromSource = @"QQ";
             [self thirdRegister: user.uid userName: user.nickname];
         }
         
         else
         {
             NSLog(@"%@",error);
         }
         
     }];
}

#pragma mark=== 微信的登录
- (void) otherLoginWeixin{
    
    [ShareSDK getUserInfo:SSDKPlatformTypeWechat
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess)
         {
             
             NSLog(@"uid=%@",user.uid);
             NSLog(@"%@",user.credential);
             NSLog(@"token=%@",user.credential.token);
             NSLog(@"nickname=%@",user.nickname);
             fromSource = @"weixin";
             [self thirdRegister: user.uid userName: user.nickname];
         }
         
         else
         {
             NSLog(@"%@",error);
         }
         
     }];
}

#pragma mark=== 微博的登录

- (void) otherLoginWeibo{
    
    [ShareSDK getUserInfo:SSDKPlatformTypeSinaWeibo
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess)
         {
             NSLog(@"uid=%@",user.uid);
             NSLog(@"%@",user.credential);
             NSLog(@"token=%@",user.credential.token);
             NSLog(@"nickname=%@",user.nickname);
             fromSource = @"weibo";
             [self thirdRegister: user.uid userName: user.nickname];
         }         
         else
         {
             NSLog(@"%@",error);
         }
         
     }];
}

#pragma mark========请求服务器,注册第三方账号到自己的服务器

- (void) thirdRegister:(NSString *) uid userName:(NSString *) nickName{
    
    //登录完的地址
    NSString * urlPath = [NSString stringWithFormat:@"http://ys.mzys365.com/index.php?route=account/register/thirdregister&openid=%@&username=%@&from=%@",uid,nickName,fromSource];
    urlPath = [urlPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSLog(@"++%@",urlPath);
    //AFNetworking 请求服务器管理器
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    [manager setSecurityPolicy:securityPolicy];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET: urlPath parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"访问成功");
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlPath]]];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error=====%@",error);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
