//
//  TCViewController.m
//  Hekr
//
//  Created by Mario on 15/6/29.
//  Copyright (c) 2015年 Michael Hu. All rights reserved.
//

#import "TCViewController.h"
#import <AFNetworking.h>
#import "StorageManage.h"
#import "NetworkingManage.h"
#import "DBHandler.h"

@interface TCViewController () <UITextViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *turnBack;
@property (weak, nonatomic) IBOutlet UIButton *dissMissButton;
@property (nonatomic, strong) UIAlertView *turnBackAlertView;

@end

@implementation TCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.gagSendMegButton.layer setCornerRadius:10.0];
    [self.dissMissButton.layer setCornerRadius:10.0];
    
    self.gagPlaceHolder.delegate = self;

}

- (IBAction)touchGagSendMegButton:(id)sender {
    NSLog(@"当前点击了SendButton");
    
    if (self.gagPlaceHolder.text.length < 8) {
        UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"请您继续反馈一些", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil, nil];
        [alerView show];
    }
    else if (self.gagPlaceHolder.text.length > 8) {
        
        NSString *tcStr = self.gagPlaceHolder.text;
        NSLog(@"%@", tcStr);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        //申明返回的结果是json类型
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        //申明请求的数据是json类型
        manager.requestSerializer=[AFJSONRequestSerializer serializer];
        //如果报接受类型不一致请替换一致text/html或别的
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
        
        manager. requestSerializer = [ AFHTTPRequestSerializer serializer ];
        
        manager. responseSerializer = [ AFHTTPResponseSerializer serializer ];
        
        //传入的参数
        NSString *string = [[StorageManage sharedInstance] getUserToken];
        NSLog(@"%@", string);
        
//        NSDictionary *parameters = @{@"userAccessKey":string, @"content":tcStr};
        
        //你的接口地址
//        NSString *url= @"http://poseido.hekr.me/tucao.json";
        //发送请求
        
        [NetworkingManage sendFeedback:tcStr Block:^(BOOL finish) {
            if (finish) {
                self.turnBackAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"您的反馈我们已经收到", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil, nil];
                self.turnBackAlertView.tag = 100;
                [self.turnBackAlertView show];
            }else{
                self.turnBackAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"反馈失败,请您检查您的网络", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil, nil];
                [self.turnBackAlertView show];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
//        [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"JSON: %@", responseObject);
//   
//            if (responseObject) {
//                NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//                NSLog(@"Prinft: %@", operation);
//                NSLog(@"提交成功");
//                if ([string rangeOfString:@"\"success\""].location != NSNotFound) {
//                    self.turnBackAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"您的吐槽我们已经收到", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil, nil];
//                    self.turnBackAlertView.tag = 100;
//                    [self.turnBackAlertView show];
//                } else {
//                    self.turnBackAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"吐槽失败,请您检查您的网络", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil, nil];
//                    [self.turnBackAlertView show];
//                }
//                [self dismissViewControllerAnimated:YES completion:nil];
//            }else {
//                self.turnBackAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"吐槽失败,请您检查您的网络", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil, nil];
//                [self.turnBackAlertView show];
//            }
        
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"Error: %@", error);
//        }];
        
    }

}


- (IBAction)touchGagBackButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
