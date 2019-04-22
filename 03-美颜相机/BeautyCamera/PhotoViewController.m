//
//  PhotoViewController.m
//  BeautyCamera
//
//  Created by zhaoliang chen on 2019/4/22.
//  Copyright © 2019 zhaoliang chen. All rights reserved.
//

#import "PhotoViewController.h"
#import "GPUImage.h"

@interface PhotoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) GPUImageStillCamera* camera;
@property (strong, nonatomic) GPUImageBrightnessFilter* filter;
@property (strong, nonatomic) GPUImageView* preview;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 1.添加美白滤镜
    self.filter = [[GPUImageBrightnessFilter alloc]init];
    self.filter.brightness = 0.5;
    // 2.将美白滤镜添加进相机
    [self.camera addTarget:self.filter];
    // 3.创建GPUImageView,用于显示实时画面
    self.preview = [[GPUImageView alloc]initWithFrame:self.view.bounds];
    self.preview.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:self.preview atIndex:0];
    [self.filter addTarget:self.preview];
}

- (void)viewDidAppear:(BOOL)animated {
    
    // 4.开始捕捉
    [self.camera startCameraCapture];
    
}

- (IBAction)onTakePhoto:(id)sender {
    [self.camera capturePhotoAsImageProcessedUpToFilter:self.filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        self.imageView.image = processedImage;
        [self.camera stopCameraCapture];
        [self.preview removeFromSuperview];
    }];
}

- (GPUImageStillCamera*)camera {
    if (!_camera) {
        // 1.创建GPUImageStillCamera
        _camera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
        
        // 2.设置竖直方向
        _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
        
        
    }
    return _camera;
}

@end
