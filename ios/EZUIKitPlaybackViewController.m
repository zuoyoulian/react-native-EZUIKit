//
//  EZUIKitPlaybackViewController.m
//  EZUIKit
//
//  Created by 左建军 on 2018/3/23.
//  Copyright © 2018年 tuofeng. All rights reserved.
//

#import "EZUIKitPlaybackViewController.h"
#import "EZUIKit.h"
#import "EZUIPlayer.h"
#import "EZUIError.h"
#import "Toast+UIView.h"
#import "EZPlaybackProgressBar.h"
#import "EZDeviceRecordFile.h"
#import "EZCloudRecordFile.h"

@interface EZUIKitPlaybackViewController () <EZUIPlayerDelegate,EZPlaybackProgressDelegate>

@property (nonatomic,strong) EZUIPlayer *mPlayer;
@property (nonatomic,strong) UIButton *playBtn;
@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) EZPlaybackProgressBar *playProgressBar;

@end

@implementation EZUIKitPlaybackViewController

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

- (void)dealloc
{
    [self releasePlayer];
}

#pragma mark - play bar delegate

- (void) EZPlaybackProgressBarScrollToTime:(NSDate *)time {
    if (!self.mPlayer)
    {
        return;
    }
    
    self.playBtn.selected = YES;
    [self.mPlayer seekToTime:time];
}

#pragma mark - player delegate

- (void) EZUIPlayerPlayTime:(NSDate *)osdTime {
    [self.playProgressBar scrollToDate:osdTime];
}

- (void) EZUIPlayerFinished {
    [self stop];
    self.playBtn.selected = NO;
}

- (void) EZUIPlayerPrepared {
    if ([EZUIPlayer getPlayModeWithUrl:self.urlStr] ==  EZUIKIT_PLAYMODE_REC)
    {
        [self createProgressBarWithList:self.mPlayer.recordList];
    }
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
    else if ([error.errorString isEqualToString:UE_ERROR_CAMERA_NOT_EXIST] ||
             [error.errorString isEqualToString:UE_ERROR_DEVICE_NOT_EXIST])
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


#pragma mark - support

- (void) createProgressBarWithList:(NSArray *) list {
    NSMutableArray *destList = [NSMutableArray array];
    for (id fileInfo in list)
    {
        EZPlaybackInfo *info = [[EZPlaybackInfo alloc] init];
        
        if  ([fileInfo isKindOfClass:[EZDeviceRecordFile class]])
        {
            info.beginTime = ((EZDeviceRecordFile*)fileInfo).startTime;
            info.endTime = ((EZDeviceRecordFile*)fileInfo).stopTime;
            info.recType = 2;
        }
        else
        {
            info.beginTime = ((EZCloudRecordFile*)fileInfo).startTime;
            info.endTime = ((EZCloudRecordFile*)fileInfo).stopTime;
            info.recType = 1;
        }
        
        [destList addObject:info];
    }
    
    if (self.playProgressBar)
    {
        [self.playProgressBar updateWithDataList:destList];
        [self.playProgressBar scrollToDate:((EZPlaybackInfo*)[destList firstObject]).beginTime];
        return;
    }
    
    self.playProgressBar = [[EZPlaybackProgressBar alloc] initWithFrame:CGRectMake(0, 430,
                                                                                   [UIScreen mainScreen].bounds.size.width,
                                                                                   100)
                                                               dataList:destList];
    self.playProgressBar.delegate = self;
    self.playProgressBar.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.playProgressBar];
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
//    self.mPlayer.customIndicatorView = nil;//设置为nil则去除加载动画
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
