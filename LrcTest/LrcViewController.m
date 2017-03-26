//
//  ViewController.m
//  LrcTest
//
//  Created by pengyucheng on 08/03/2017.
//  Copyright © 2017 PBBReader. All rights reserved.
//

#import "LrcViewController.h"

@interface LrcViewController (private)
-(void) setupAVPlayerForURL: (NSURL*) url;
-(void) playAudio:(id) sender;
-(void) pauseAudio:(id) sender;
-(Float64) currentPlayTime;
-(int) currentPlayIndex:(NSString*) currentPlaySecond;

@end

@implementation LrcViewController
{
    UIView *_lrcView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(void)loadView
{
    [super loadView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:@"播放" forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(50, 420, 60, 35)];
    [btn addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];//100, 420, 60, 25
    
    
    UIButton *btnPause = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnPause setTitle:@"暂停" forState:UIControlStateNormal];
    [btnPause setFrame:CGRectMake(200, 420, 60, 35)];
    [btnPause addTarget:self action:@selector(pauseAudio:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *pushBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [pushBtn setTitle:@"model animater" forState:UIControlStateNormal];
    [pushBtn setFrame:CGRectMake(200, 500, 60, 35)];
    [pushBtn addTarget:self action:@selector(pushAnimate:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pushBtn];
    
    
    UIButton *pushBtn1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [pushBtn1 setTitle:@"table" forState:UIControlStateNormal];
    [pushBtn1 setFrame:CGRectMake(200, 550, 60, 35)];
    [pushBtn1 addTarget:self action:@selector(pushLayerTable) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pushBtn1];
    
    _lrcView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 340, 400)];
    [self.view addSubview:_lrcView];
    
    [self.view addSubview:btnPause];//100, 420, 60, 25
   
   
}

-(void)pushLayerTable
{
    //self.navigationController?.pushViewController(LayerTableView(), animated: false)
    LayerTableView *table = [LayerTableView new];
    [[self navigationController] pushViewController:table animated:false];
}

-(void)pushAnimate:(NSString *)nnn
{
    ClockListView *list = [ClockListView shareInstance];
    list.delayClockDelegate = self;
    [self.view addSubview:list];
    
    return;
    
    ClockViewController *clock = [ClockViewController new];
    //clock.modalPresentationStyle = UIModalPresentationPopover;
    if (clock.modalPresentationStyle == UIModalPresentationPopover) {
        //
        UIPopoverPresentationController *popover = clock.popoverPresentationController;
        popover.delegate = self;
    }
    [self presentViewController:clock animated:YES completion:nil];
}


//播放音频文件
-(void) setupAVPlayerForURL: (NSURL*) url
{
//    AVAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
//    AVPlayerItem *anItem = [AVPlayerItem playerItemWithAsset:asset];
    
//    _player = [AVPlayer playerWithPlayerItem:anItem];
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    //添加KVO事件监听状态
//    [_player addObserver:self forKeyPath:@"status" options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _player && [keyPath isEqualToString:@"status"])
    {
        if (_player.status == AVPlayerStatusFailed)
        {
            NSLog(@"AVPlayer Failed");
        }
        else if (_player.status == AVPlayerStatusReadyToPlay)
        {
            NSLog(@"AVPlayer Ready to Play");
        }
        else if (_player.status == AVPlayerItemStatusUnknown)
        {
            NSLog(@"AVPlayer Unknown");
        }
    }
}


-(void) playAudio:(id) sender
{
    NSString * path = [[NSBundle mainBundle] pathForResource:@"qbd" ofType:@"mp3"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    [self setupAVPlayerForURL:url];
    
    //添加音频路径 01爱与痛的边缘
    NSString *lrcPath = [[NSBundle mainBundle] pathForResource:@"01爱与痛的边缘" ofType:@"lrc"];
    MusicLrcView *lrcView = [MusicLrcView shared];
//    [lrcView switchLrcOfMusic:lrcPath audioPlayer:_audioPlayer lrcDelegate:self];
    [lrcView loadLrcBy:lrcPath audioPlayer:_audioPlayer lrcDedegate:self];
    
    [_lrcView addSubview:lrcView];

    [_audioPlayer play];
    
}


-(void) pauseAudio:(id) sender
{
    
    self.exampleTransitionDelegate = [ClockTransitioningDelegate new];
    self.transitioningDelegate = self.exampleTransitionDelegate;
    ClockTableViewController *tableView = [ClockTableViewController shareInstance];
    tableView.delayClockDelegate = self;
    tableView.transitioningDelegate = self.exampleTransitionDelegate;
    tableView.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:tableView animated:NO completion:nil];
}


#pragma mark --model
-(UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[controller presentedViewController]];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    nav.topViewController.navigationItem.rightBarButtonItem = item;
    return [controller presentedViewController];
}

-(void)dismiss
{
    [super dismissViewControllerAnimated:true completion:nil];
}



-(UIColor *)musicLrcHighlightColor
{
    return [UIColor redColor];
}

-(UIColor *)musicLrcColor
{
    return [UIColor greenColor];
}

-(void)setDelayToPerformCloseOperation
{
    NSLog(@"设置时间");
}

-(void)cancelPerformCloseOperation
{
    NSLog(@"取消定时器");
}

-(void)CountingDownRefreshSencondWithTime:(NSString *)time
{
    NSLog(@"标签刷新倒计时：%@",time);
}

-(NSInteger)currentMusicTime
{
    return 15;
}
@end
