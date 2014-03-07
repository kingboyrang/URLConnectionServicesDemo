//
//  ViewController.h
//  URLConnectionServicesDemo
//
//  Created by aJia on 2014/2/21.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UILabel *labRate;
@property (retain, nonatomic) IBOutlet UIProgressView *progressView;


//同步请求
- (IBAction)buttonSyncClick:(id)sender;
//异步请求
- (IBAction)buttonAsyncClick:(id)sender;
//下载图片
- (IBAction)buttonDownloadClick:(id)sender;

@end
