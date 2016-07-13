//
//  ViewController.m
//  AVCaptureSession
//
//  Created by lvAsia on 16/7/13.
//  Copyright © 2016年 answe lv. All rights reserved.
//

#import "ViewController.h"
#import "OneViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#define kWidth ([UIScreen mainScreen].bounds.size.width)
#define kHeight ([UIScreen mainScreen].bounds.size.height)

static float kCameraScale=1.0;
@interface ViewController ()
@property(nonatomic,strong)AVCaptureSession *session;
@property(nonatomic,strong)AVCaptureDeviceInput *input;
@property(nonatomic,strong)AVCaptureStillImageOutput *output;
@property(nonatomic,strong)AVCaptureVideoPreviewLayer *previewLayer;
//拍照
@property(nonatomic,strong)UIButton *shutterBtn;
//对焦
@property(nonatomic,strong)UIView *focalReticule;
//焦距Button
@property(nonatomic,strong)UIButton *focalBtn;

//焦距



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}
//开始任务
-(void)viewDidAppear:(BOOL)animated
{
[super viewDidAppear:animated];
[_session startRunning];
}
//å停止任务
-(void)viewWillDisappear:(BOOL)animated
{
[super viewWillDisappear:animated];
[_session stopRunning];
}
//初始化抓取任务
-(void)setUpSession
{
_session=[[AVCaptureSession alloc]init];
AVCaptureDevice *device=nil;
NSArray *devices=[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
for(AVCaptureDevice *tmp in devices)
{
if(tmp.position==AVCaptureDevicePositionBack)
device=tmp;
}
_input=[[AVCaptureDeviceInput alloc]initWithDevice:device error:nil];
_output=[[AVCaptureStillImageOutput alloc]init];
_output.outputSettings=@{AVVideoCodecKey:AVVideoCodecJPEG};
if([_session canAddInput:_input])
[_session addInput:_input];
if([_session canAddOutput:_output])
[_session addOutput:_output];
}
//初始化相机预览层
-(void)initCameraLayer
{
_previewLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:_session];
//self.view.layer.masksToBounds=YES;
[self.previewLayer setFrame:self.view.bounds];
[self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
[self.view.layer addSublayer:_previewLayer];
}
//æ搭建UI
-(void)ceateUI
{
//拍站按钮
_shutterBtn=[[UIButton alloc]initWithFrame:CGRectMake(kWidth-50, kHeight-60, 30, 40)];
//[_shutterBtn setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
//[_shutterBtn setImage:[UIImage imageNamed:@"camera_h"] forState:UIControlStateHighlighted];
    [_shutterBtn setTitle:@"cramera" forState:UIControlStateNormal];
    [_shutterBtn setBackgroundColor:[UIColor redColor]];
[self.view addSubview:_shutterBtn];
[_shutterBtn addTarget:self action:@selector(shutter) forControlEvents:UIControlEventTouchUpInside];
_shutterBtn.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.8];
_shutterBtn.layer.cornerRadius=10;
_shutterBtn.imageEdgeInsets=UIEdgeInsetsMake(10, 5, 10, 5);
_shutterBtn.layer.borderColor=[UIColor whiteColor].CGColor;
_shutterBtn.layer.borderWidth=1;
//对焦十字
_focalReticule=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
_focalReticule.backgroundColor=[UIColor clearColor];
//十字
UIView *line1=[[UIView alloc]initWithFrame:CGRectMake(0, 29.5, 60, 1)];
line1.backgroundColor=[UIColor whiteColor];
[_focalReticule addSubview:line1];
UIView *line2=[[UIView alloc]initWithFrame:CGRectMake(29.5, 0, 1, 60)];
line2.backgroundColor=[UIColor whiteColor];
[_focalReticule addSubview:line2];
[self.view addSubview:_focalReticule];
//默认隐藏
_focalReticule.hidden=YES;
//点击屏幕对焦的手势
UITapGestureRecognizer *foucusTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(foucus:)];
[self.view addGestureRecognizer:foucusTap];
}
//功能性UI
-(void)createFunctionalUI
{
//1x 2x 3x 4x对焦®
_focalBtn=[[UIButton alloc]initWithFrame:CGRectMake(20, kHeight-110, 40, 30)];
[_focalBtn setTitle:@"1X" forState:UIControlStateNormal];
[_focalBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
_focalBtn.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.8];
_focalBtn.layer.cornerRadius=10;
_focalBtn.layer.borderColor=[UIColor whiteColor].CGColor;
_focalBtn.layer.borderWidth=1.0;
_focalBtn.transform=CGAffineTransformMakeRotation(M_PI_2);
[_focalBtn addTarget:self action:@selector(adjustFocalDistance:) forControlEvents:UIControlEventTouchUpInside];
[self.view addSubview:_focalBtn];
CGRect frame=_focalBtn.frame;
frame.origin.x=_shutterBtn.frame.origin.x;
_focalBtn.frame=frame;
//闪光灯开启后关闭按钮
UIButton *flashBtn=[[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_shutterBtn.frame), 20, 40, 30)];
flashBtn.transform=CGAffineTransformMakeRotation(M_PI_2);
[flashBtn setTitle:@"âš¡ï¸å…³" forState:UIControlStateNormal];
[flashBtn setTitle:@"âš¡ï¸å¼€" forState:UIControlStateSelected];
[flashBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
flashBtn.titleLabel.font=[UIFont systemFontOfSize:12];
flashBtn.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.8];
flashBtn.layer.cornerRadius=10;
flashBtn.layer.borderColor=[UIColor whiteColor].CGColor;
flashBtn.layer.borderWidth=1;
[self.view addSubview:flashBtn];
[flashBtn addTarget:self action:@selector(flasAction:) forControlEvents:UIControlEventTouchUpInside];
//切换前后摄像头
UIButton *shiftBtn=[[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_shutterBtn.frame), 80, 40, 30)];
shiftBtn.transform=CGAffineTransformMakeRotation(M_PI_2);
[shiftBtn setImage:[UIImage imageNamed:@"shift"] forState:UIControlStateNormal];
shiftBtn.imageEdgeInsets=UIEdgeInsetsMake(5, 10, 5, 10);
[shiftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
shiftBtn.titleLabel.font=[UIFont systemFontOfSize:12];
shiftBtn.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.8];
shiftBtn.layer.cornerRadius=10;
shiftBtn.layer.borderColor=[UIColor whiteColor].CGColor;
shiftBtn.layer.borderWidth=1;
[self.view addSubview:shiftBtn];
[shiftBtn addTarget:self action:@selector(shiftCamera:) forControlEvents:UIControlEventTouchUpInside];
}
//切换前后相机
-(void)shiftCamera:(UIButton *)sender
{
sender.selected=!sender.isSelected;
//切换至前置摄像头
if(sender.isSelected)
{
AVCaptureDevice *device=nil;
NSArray *devices=[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
for(AVCaptureDevice *tmp in devices)
{
if(tmp.position==AVCaptureDevicePositionFront)
device=tmp;
}
[_session beginConfiguration];
[_session removeInput:_input];
_input=nil;
_input=[[AVCaptureDeviceInput alloc]initWithDevice:device error:nil];
if([_session canAddInput:_input])
[_session addInput:_input];
[_session commitConfiguration];
}
//切换至后置摄像头
else
{
AVCaptureDevice *device=nil;
NSArray *devices=[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
for(AVCaptureDevice *tmp in devices)
{
if(tmp.position==AVCaptureDevicePositionBack)
device=tmp;
}
[_session beginConfiguration];
[_session removeInput:_input];
_input=nil;
_input=[[AVCaptureDeviceInput alloc]initWithDevice:device error:nil];
if([_session canAddInput:_input])
[_session addInput:_input];
[_session commitConfiguration];
}
}
//闪光灯按钮操作
-(void)flasAction:(UIButton *)sender
{
sender.selected=!sender.isSelected;
AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
if ([device hasTorch] && [device hasFlash])
{
[device lockForConfiguration:nil];
//闪光的打开
if (sender.isSelected)
{
[device setFlashMode:AVCaptureFlashModeOn];
}
//闪光的关闭
else
{
[device setFlashMode:AVCaptureFlashModeOff];
}
//闪光灯自动，这里就不写了，可以自己尝试
//[device setFlashMode:AVCaptureFlashModeAuto];
[device unlockForConfiguration];
}
}
//调整焦距·
-(void)adjustFocalDistance:(UIButton *)sender
{
kCameraScale+=1.0;
if(kCameraScale>4.0)
kCameraScale=1.0;
//改变焦距
AVCaptureConnection *connect=[_output connectionWithMediaType:AVMediaTypeVideo];
[CATransaction begin];
[CATransaction setAnimationDuration:0.2];
[_focalBtn setTitle:[NSString stringWithFormat:@"%dX",(int)kCameraScale] forState:UIControlStateNormal];
[_previewLayer setAffineTransform:CGAffineTransformMakeScale(kCameraScale, kCameraScale)];
connect.videoScaleAndCropFactor=kCameraScale;
[CATransaction commit];
}
//对焦
-(void)foucus:(UITapGestureRecognizer *)sender
{
if(_input.device.position==AVCaptureDevicePositionFront)
return;
if(sender.state==UIGestureRecognizerStateRecognized)
{
CGPoint location=[sender locationInView:self.view];
//对焦
__weak typeof(self) weakSelf=self;
[self focusOnPoint:location completionHandler:^{
weakSelf.focalReticule.center=location;
weakSelf.focalReticule.alpha=0.0;
weakSelf.focalReticule.hidden=NO;
[UIView animateWithDuration:0.3 animations:^{
weakSelf.focalReticule.alpha=1.0;
}completion:^(BOOL finished) {
[UIView animateWithDuration:0.3 animations:^{
weakSelf.focalReticule.alpha=0.0;
}];
}];
}];
}
}
//对某一点聚焦
-(void)focusOnPoint:(CGPoint)point completionHandler:(void(^)())completionHandler
{
AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];;
CGPoint pointOfInterest = CGPointZero;
CGSize frameSize = self.view.bounds.size;
pointOfInterest = CGPointMake(point.y / frameSize.height, 1.f - (point.x / frameSize.width));
if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
{
NSError *error;
if ([device lockForConfiguration:&error])
{
if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance])
{
[device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
}
if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
{
[device setFocusMode:AVCaptureFocusModeAutoFocus];
[device setFocusPointOfInterest:pointOfInterest];
}
if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
{
[device setExposurePointOfInterest:pointOfInterest];
[device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
}
[device unlockForConfiguration];
if(completionHandler)
completionHandler();
}
}
else
{
if(completionHandler)
completionHandler();
}
}
//æ‹ç…§
-(void)shutter
{
AVCaptureConnection *connect=[_output connectionWithMediaType:AVMediaTypeVideo];
if(!connect)
{
NSLog(@"æ‹ç…§å¤±è´¥");
return;
}
__weak typeof(self) weakSelf=self;
[_output captureStillImageAsynchronouslyFromConnection:connect completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
if(imageDataSampleBuffer==NULL)
return;
NSData *imageData=[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
UIImage *image=[UIImage imageWithData:imageData];
[weakSelf shutterSuccessAlert];
[weakSelf showCapturedImage:image];
}];
}
//æ˜¾ç¤ºæ‹æ‘„åˆ°çš„ç…§ç‰‡
-(void)showCapturedImage:(UIImage *)image
{
UIImageView *imv=[[UIImageView alloc]initWithFrame:self.view.bounds];
imv.image=image;
if(_input.device.position==AVCaptureDevicePositionFront)
imv.transform=CGAffineTransformMakeRotation(M_PI);
[self.view addSubview:imv];
imv.userInteractionEnabled=YES;
CGFloat xpos=20;
CGFloat ypos=100;
if(_input.device.position==AVCaptureDevicePositionFront)
{
xpos=kWidth-80;
ypos=kHeight-100;
}
UIButton *cancelBtn=[[UIButton alloc]initWithFrame:CGRectMake(xpos, ypos, 60, 40)];
[cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
[cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
cancelBtn.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.8];
cancelBtn.layer.cornerRadius=5;
cancelBtn.layer.borderColor=[UIColor whiteColor].CGColor;
cancelBtn.layer.borderWidth=1.0;
[cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
CGFloat raduis=M_PI_2;
if(_input.device.position==AVCaptureDevicePositionFront) raduis= M_PI_2;
cancelBtn.transform=CGAffineTransformMakeRotation(raduis);
[imv addSubview:cancelBtn];
UIButton *saveBtn=[[UIButton alloc]initWithFrame:CGRectMake(xpos, kHeight-ypos, 60, 40)];
[saveBtn setTitle:@"保存" forState:UIControlStateNormal];
[saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
saveBtn.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.8];
saveBtn.layer.cornerRadius=5;
saveBtn.layer.borderColor=[UIColor whiteColor].CGColor;
saveBtn.layer.borderWidth=1.0;
[saveBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
saveBtn.transform=CGAffineTransformMakeRotation(raduis);
[imv addSubview:saveBtn];
}
//取消
-(void)cancel:(UIButton *)sender
{
[sender.superview removeFromSuperview];
}
//保存
-(void)save:(UIButton *)sender
{
UIImageView *imv=(UIImageView *)sender.superview;
//调用相册
UIImageWriteToSavedPhotosAlbum(imv.image, nil, nil, nil);
[imv removeFromSuperview];
}
//播放拍照音效
-(void)shutterSuccessAlert
{
//播放音效
SystemSoundID soundID;
AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sound.mp3" ofType:nil]],&soundID);
//播放短银屏
AudioServicesPlaySystemSound(soundID);
//整栋
AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
//éšè—çŠ¶æ€æ 
-(BOOL)prefersStatusBarHidden
{
return YES;
}





- (IBAction)nextViewVC:(id)sender {
    OneViewController *VC = [[OneViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
    NSLog(@"------");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end