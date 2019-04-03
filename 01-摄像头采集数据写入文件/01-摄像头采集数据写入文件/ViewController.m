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
<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,AVCaptureFileOutputRecordingDelegate>

//捕捉画面的session
@property(nonatomic,strong)AVCaptureSession* session;
//视频文件输出的uoutput
@property(nonatomic,strong)AVCaptureVideoDataOutput* videoOutput;
//展示预览图层的layer
@property(nonatomic,strong)AVCaptureVideoPreviewLayer* previewLayer;
//视频文件输入的intput
@property(nonatomic,strong)AVCaptureDeviceInput* videoInput;
//视频文件输出的output
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

//初始化音频输入输出流
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

//初始化预览图层
- (void)setupPreviewLayer {
    AVCaptureVideoPreviewLayer* layer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    if (layer == nil) {
        return;
    }
    layer.frame = self.view.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    self.previewLayer = layer;
}

//创建视频文件写入的movieOutput
- (void)setupMovieFileOutput {
    if (self.movieOutput) {
        [self.session removeOutput:self.movieOutput];
    }
    
    AVCaptureMovieFileOutput* movieOutput = [[AVCaptureMovieFileOutput alloc]init];
    self.movieOutput = movieOutput ;

    AVCaptureConnection *connect = [movieOutput connectionWithMediaType:AVMediaTypeVideo];
    connect.automaticallyAdjustsVideoMirroring = YES;
    connect.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    if ([self.session canAddOutput:movieOutput]) {
        [self.session addOutput:movieOutput];
        
        //视频文件的写入
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)lastObject] stringByAppendingPathComponent:@"test.mp4"];
        
        [movieOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:filePath] recordingDelegate:self];
    }
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (connection == [self.videoOutput connectionWithMediaType:AVMediaTypeVideo]) {
        //NSLog(@"采集到视频");
    } else {
        //NSLog(@"采集到音频");
    }
}

- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections {
    NSLog(@"开始写入视频文件");
}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error {
    NSLog(@"结束写入视频文件");
}


- (IBAction)startCapture:(id)sender {
    if (self.session.isRunning) {
        return;
    }
    [self.session startRunning];
    
    [self setupPreviewLayer];
    
    [self setupMovieFileOutput];
}

- (IBAction)stopCapture:(id)sender {
    [self.session stopRunning];
    
    [self.previewLayer removeFromSuperlayer];
    
    [self.movieOutput stopRecording];
}

- (IBAction)switchCamera:(id)sender {
    if (self.videoInput != nil) {
        //先获取原来的摄像头反向，转换摄像头
        AVCaptureDevicePosition position = self.videoInput.device.position == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
        
        //重新设置一个新的输入源
        NSArray<AVCaptureDevice*>* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        if (devices.count < 1) {
            return;
        }
        __block AVCaptureDevice* device = nil;
        [devices enumerateObjectsUsingBlock:^(AVCaptureDevice * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.position == position) {
                device = obj;
                *stop = YES;
            }
        }];
        if (device == nil) {
            return;
        }
        AVCaptureDeviceInput* newInput = [[AVCaptureDeviceInput alloc]initWithDevice:device error:nil];
        if (newInput == nil) {
            return;
        }
        
        //移除旧的输入源，添加新的输入源
        [self.session beginConfiguration];
        [self.session removeInput:self.videoInput];
        if ([self.session canAddInput:newInput]) {
            [self.session addInput:newInput];
        }
        [self.session commitConfiguration];
        self.videoInput = newInput;
    }
}

- (AVCaptureSession*)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc]init];
    }
    return _session;
}

@end
