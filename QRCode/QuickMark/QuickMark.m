//
//  QuickMark.m
//  ShareView
//
//  Created by dxs on 2017/5/8.
//  Copyright © 2017年 dxs. All rights reserved.
//

#import "QuickMark.h"
#import "QuickMarkScanView.h"

@interface QuickMark ()<AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong,nonatomic) AVCaptureSession * captureSession;
@property (strong, nonatomic) QuickMarkScanView *scanView;

@end

@implementation QuickMark

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"扫一扫";
    self.extendedLayoutIncludesOpaqueBars = YES;
     _scanView = [[QuickMarkScanView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_scanView];
    [self initCaptureProperties];
}

#pragma mark - 扫描二维码
/** 扫描二维码方法 */
- (void)initCaptureProperties {
    //获取摄像设备
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (captureDevice) {
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if (AVAuthorizationStatusNotDetermined == authStatus) {
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                //未决定
                if (granted) {
                    __weak QuickMark *weakSelf = self;
                    [weakSelf initCapturePropertiesWithDevice:captureDevice];
                } else {
                    NSString *message = [NSString stringWithFormat:@"请去-> [设置 - 隐私 - 相机 - %@]", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
                    [self presentAlertViewControllerWithMessage:message confirmAction:YES cancelAction:YES];
                }
            }];
            
        } else if (AVAuthorizationStatusDenied == authStatus || AVAuthorizationStatusRestricted == authStatus) {
            NSString *message = [NSString stringWithFormat:@"请去-> [设置 - 隐私 - 相机 - %@]", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
            [self presentAlertViewControllerWithMessage:message confirmAction:YES cancelAction:YES];
            
        } else {
            
            __weak QuickMark *weakSelf = self;
            [weakSelf initCapturePropertiesWithDevice:captureDevice];
            
        }
        
    } else {
        
        [self presentAlertViewControllerWithMessage:@"设备不支持" confirmAction:NO cancelAction:YES];
        
    }
}

- (void)initCapturePropertiesWithDevice:(AVCaptureDevice *)captureDevice {
    //创建输入流
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
    //创建输出流
    AVCaptureMetadataOutput *deviceOutput = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [deviceOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //初始化链接对象
    _captureSession = [[AVCaptureSession alloc] init];
    //高质量采集率
    [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([_captureSession canAddInput:deviceInput]) {
        [_captureSession addInput:deviceInput];
    }
    if ([_captureSession canAddOutput:deviceOutput]) {
        [_captureSession addOutput:deviceOutput];
    }
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    deviceOutput.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    [deviceOutput setRectOfInterest:CGRectMake (CGRectGetMinY(_scanView.scanContent_layer.frame)/CGRectGetHeight(self.view.frame) ,(_scanView.scanContent_layer.frame.origin.x)/CGRectGetWidth(self.view.frame), (CGRectGetWidth(self.view.frame)-2*CGRectGetMinX(_scanView.scanContent_layer.frame))/CGRectGetHeight(self.view.frame), (CGRectGetWidth(self.view.frame)-2*CGRectGetMinX(_scanView.scanContent_layer.frame))/CGRectGetWidth(self.view.frame))];
    
    if (_captureSession) {
        AVCaptureVideoPreviewLayer * captureLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
        captureLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        captureLayer.frame = self.view.bounds;
        [self.view.layer insertSublayer:captureLayer atIndex:0];
        //开始捕获
        [_captureSession startRunning];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_captureSession stopRunning];
            [self backToPrefixViewController];
        });
    }
    
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        
        [_captureSession stopRunning];
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            if (metadataObj.stringValue) {
                
                self.quickMarkResultBlock(metadataObj);
                [_captureSession stopRunning];
                [self backToPrefixViewController];
            }
            
        } else {
            
            self.quickMarkResultBlock(metadataObj);
            [_captureSession stopRunning];
            [self backToPrefixViewController];
        }
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)presentAlertViewControllerWithMessage:(NSString *)message confirmAction:(BOOL)confirm cancelAction:(BOOL)cancel {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    if (cancel) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            __weak QuickMark *weakSelf = self;
            [weakSelf backToPrefixViewController];
        }];
        [alertVC addAction:cancelAction];
    }
    if (confirm) {
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }];
        
        [alertVC addAction:confirmAction];
    }
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)backToPrefixViewController {
    if (self.navigationController.viewControllers > 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)dealloc {
    [[_scanView valueForKeyPath:@"timer"] invalidate];
    _captureSession = nil;
    _scanView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
