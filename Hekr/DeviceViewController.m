 //
//  DeviceViewController.m
//  Hekr
//
//  Created by Michael Scofield on 2015-06-26.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import "DeviceViewController.h"
#import "NetworkingManage.h"
#import <MJRefresh.h>
#import <QuartzCore/QuartzCore.h>

@interface DeviceViewController ()
@end

@implementation DeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) wself = self;
    [self.webView.scrollView addLegendHeaderWithRefreshingBlock:^{
        typeof(self) sself = wself;
        [sself.webView reload];
    }];
    [self.webView.scrollView setAlwaysBounceVertical:YES];
    
    if (self.urlString) {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.urlString]];
        
        [self.webView loadRequest:request];
        self.webView.delegate=self;
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, self.webView.frame.size.width * 2, self.webView.frame.size.height * 2);
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[UIColor colorWithRed:92/255.0 green:96/255.0 blue:161/255.0 alpha:1].CGColor,
                           (id)[UIColor colorWithRed:88/255.0 green:162/255.0 blue:167/255.0 alpha:1].CGColor,nil];
        [self.webView.layer insertSublayer:gradient atIndex:0];

    }
    UIPanGestureRecognizer *recognizer;
    recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom)];
    [self.view addGestureRecognizer:recognizer];
       // Do any additional setup after loading the view from its nib.
    
    /*
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"background"];
    [self.view addSubview:imageView];
    */
    
}
-(void)handleSwipeFrom
{
    return;
}

#pragma mark - 暂时取消定时
/*
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(cancelWeb) userInfo:nil repeats:NO];
}
- (void)cancelWeb
{
    [KVNProgress showErrorWithStatus:@"加载失败" completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
*/

-(IBAction)goBack:(id)sender
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self.webView.scrollView.header endRefreshing];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.webView.scrollView.header endRefreshing];
    NSLog(@"webView.request.URL:  %@",webView.request.URL);

    if ([webView.request.URL.absoluteString hasPrefix:@"http://login.hekr.me/success.htm?"] || [webView.request.URL.absoluteString  hasPrefix:@"http://login.smartmatrix.mx/success.htm?"]) {
        NSLog(@"进入..");
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Do time-consuming task in background thread
            // Return back to main thread to update UI
            [NetworkingManage loginByQQ:webView.request.URL.absoluteString Block:^(BOOL finish) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                // Update UI
                    if (finish) {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
            });
        }];
    });
        
        
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.isShowNav) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!self.isShowNav) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
