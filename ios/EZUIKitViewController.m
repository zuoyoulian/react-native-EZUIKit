//
//  EZUIKitViewController.m
//  EZUIKit
//
//  Created by 左建军 on 2018/3/23.
//  Copyright © 2018年 tuofeng. All rights reserved.
//

#import "EZUIKitViewController.h"
#import "EZUIKit.h"
#import "EZUIPlayer.h"
#import "EZUIError.h"
#import "Toast+UIView.h"

@interface EZUIKitViewController () <EZUIPlayerDelegate>

@property (nonatomic,strong) EZUIPlayer *mPlayer;
@property (nonatomic,strong) UIButton *playBtn;
@property (nonatomic,strong) UIButton *backButton;

@end

@implementation EZUIKitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    CATransform3D transform = CATransform3DMakeRotation(M_PI / 2, 0, 0, 1.0);
    self.view.layer.transform = transform;
  }
  return self;
}

- (void) lazyLoadButton {
  CGFloat mainScreenWidth = CGRectGetWidth(self.view.bounds);
  if (!_backButton) {
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setTitle:@"退出" forState:UIControlStateNormal];
    self.backButton.frame = CGRectMake(0, 0, 80, 40);
    [self.backButton setBackgroundColor:[UIColor clearColor]];
    [self.backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
  }
  if (!_playBtn) {
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [self.playBtn setTitle:@"停止" forState:UIControlStateSelected];
    self.playBtn.frame = CGRectMake(mainScreenWidth - 80, 0, 80, 40);
    [self.playBtn setBackgroundColor:[UIColor clearColor]];
    [self.playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playBtn];
  }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
  
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.appKey || self.appKey.length == 0 ||
        !self.accessToken || self.accessToken.length == 0 ||
        !self.urlStr || self.urlStr == 0)
    {
        return;
    }
    
    [EZUIKit initWithAppKey:self.appKey];
    
    [EZUIKit setAccessToken:self.accessToken];
    [self play];
    self.playBtn.selected = YES;
}

- (void)dealloc {
    [self releasePlayer];
}

#pragma mark - player delegate

- (void) EZUIPlayerFinished {
    [self stop];
    self.playBtn.selected = NO;
}

- (void) EZUIPlayerPrepared {
    [self play];
}

- (void) EZUIPlayerPlaySucceed:(EZUIPlayer *)player {
    self.playBtn.selected = YES;
}

- (void) EZUIPlayer:(EZUIPlayer *)player didPlayFailed:(EZUIError *) error {
    [self stop];
    self.playBtn.selected = NO;
    
    if ([error.errorString isEqualToString:UE_ERROR_INNER_VERIFYCODE_ERROR])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@)",@"验证码错误",error.errorString] duration:1.5 position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_TRANSF_DEVICE_OFFLINE])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@)",@"设备不在线",error.errorString] duration:1.5 position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_DEVICE_NOT_EXIST])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@)",@"设备不存在",error.errorString] duration:1.5 position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_CAMERA_NOT_EXIST])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@)",@"通道不存在",error.errorString] duration:1.5 position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_INNER_STREAM_TIMEOUT])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@)",@"连接超时",error.errorString] duration:1.5 position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_CAS_MSG_PU_NO_RESOURCE])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@)",@"设备连接数过大",error.errorString] duration:1.5 position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_NOT_FOUND_RECORD_FILES])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@)",@"未找到录像文件",error.errorString] duration:1.5 position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_PARAM_ERROR])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@)",@"参数错误",error.errorString] duration:1.5 position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_URL_FORMAT_ERROR])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@)",@"播放url格式错误",error.errorString] duration:1.5 position:@"center"];
    }
    else
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@)",@"播放失败",error.errorString] duration:1.5 position:@"center"];
    }
    
  NSLog(@"play error:%@(%ld)",error.errorString,(long)error.internalErrorCode);
}

- (void) EZUIPlayer:(EZUIPlayer *)player previewWidth:(CGFloat)pWidth previewHeight:(CGFloat)pHeight {
    CGFloat ratio = pWidth/pHeight;
    
    CGFloat destWidth = CGRectGetWidth(self.view.bounds);
    CGFloat destHeight = destWidth/ratio;
    
    [player setPreviewFrame:CGRectMake(0, CGRectGetMinY(player.previewView.frame), destWidth, destHeight)];
}


#pragma mark - actions

- (void) playBtnClick:(UIButton *) btn {
    if(btn.selected)
    {
        [self stop];
    }
    else
    {
        [self play];
    }
    btn.selected = !btn.selected;
}

- (void) backButtonClick:(UIButton *)btn {
  [self stop];
  __weak typeof(*&self) weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    [weakSelf dismissViewControllerAnimated:YES completion:^{
    }];
  });
}

#pragma mark - player

- (void) play {
    if (self.mPlayer)
    {
        [self.mPlayer startPlay];
        return;
    }
    
    self.mPlayer = [EZUIPlayer createPlayerWithUrl:self.urlStr];
    self.mPlayer.mDelegate = self;
  [self.mPlayer setPreviewFrame:CGRectMake(0, 0,
                                           CGRectGetWidth(self.view.bounds),
                                           CGRectGetHeight(self.view.bounds))];
  
    [self.view addSubview:self.mPlayer.previewView];
  
  [self lazyLoadButton];
}

- (void) stop {
    if (!self.mPlayer)
    {
        return;
    }
    
    [self.mPlayer stopPlay];
}

- (void) releasePlayer {
    if (!self.mPlayer)
    {
        return;
    }
    
    [self.mPlayer.previewView removeFromSuperview];
    [self.mPlayer releasePlayer];
    self.mPlayer = nil;
}

@end
