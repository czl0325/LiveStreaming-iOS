//
//  ViewController.m
//  01-摄像头采集数据写入文件
//
//  Created by zhaoliang chen on 2019/3/31.
//  Copyright © 2019 zhaoliang chen. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

//捕捉画面的session
@property(nonatomic,strong)AVCaptureSession* session;
//
@property(nonatomic,strong)AVCaptureVideoDataOutput* videoOutput;
//展示预览图层的layer
@property(nonatomic,strong)AVCaptureVideoPreviewLayer* previewLayer;
//
@property(nonatomic,strong)AVCaptureDeviceInput* videoInput;
//
@property(nonatomic,strong)AVCaptureMovieFileOutput* movieOutput;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupVideoIntputOutput];
    
    [self setupAudioIntputOutput];
}
//初始化视频输入输出
- (void)setupVideoIntputOutput {
    NSArray<AVCaptureDevice*>* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (devices.count < 1) {
        return;
    }
    __block AVCaptureDevice* device = nil;
    [devices enumerateObjectsUsingBlock:^(AVCaptureDevice * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.position == AVCaptureDevicePositionFront) {
            device = obj;
            *stop = YES;
        }
    }];
    if (device == nil) {
        return;
    }
    AVCaptureDeviceInput* input = [[AVCaptureDeviceInput alloc]initWithDevice:device error:nil];
    if (input == nil) {
        return;
    }
    self.videoInput = input;
    
    AVCaptureVideoDataOutput* output = [[AVCaptureVideoDataOutput alloc]init];
    [output setAlwaysDiscardsLateVideoFrames:YES];
    dispatch_queue_t queue = dispatch_queue_create("captureVideo", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    self.videoOutput = output;
    
    [self.session beginConfiguration];
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
    }
    [self.session commitConfiguration];
}

- (void)setupAudioIntputOutput {
    AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    if (device == nil) {
        return;
    }
    AVCaptureDeviceInput* intput = [[AVCaptureDeviceInput alloc]initWithDevice:device error:nil];
    if (intput == nil) {
        return;
    }
    AVCaptureAudioDataOutput* output = [[AVCaptureAudioDataOutput alloc]init];
    dispatch_queue_t queue = dispatch_queue_create("captureAudio", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    
    [self.session beginConfiguration];
    if ([self.session canAddInput:intput]) {
        [self.session addInput:intput];
    }
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
    }
    [self.session commitConfiguration];
}

- (void)setupPreviewLayer {
    AVCaptureVideoPreviewLayer* layer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    if (layer == nil) {
        return;
    }
    layer.frame = self.view.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    self.previewLayer = layer;
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (connection == [self.videoOutput connectionWithMediaType:AVMediaTypeVideo]) {
        NSLog(@"采集到视频");
    } else {
        NSLog(@"采集到音频");
    }
}


- (IBAction)startCapture:(id)sender {
    [self.session startRunning];
    
    [self setupPreviewLayer];
}

- (IBAction)stopCapture:(id)sender {
    [self.session stopRunning];
    
    [self.previewLayer removeFromSuperlayer];
}

- (IBAction)switchCamera:(id)sender {
    
}

- (AVCaptureSession*)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc]init];
    }
    return _session;
}

@end
