//
//  ViewController.m
//  GPUImageTest
//
//  Created by zhaoliang chen on 2019/4/22.
//  Copyright © 2019 zhaoliang chen. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//添加毛玻璃效果
- (IBAction)onBlur:(id)sender {
    // 2.2.初始化高斯模糊滤镜
    GPUImageGaussianBlurFilter* blurFilter = [[GPUImageGaussianBlurFilter alloc]init];
    blurFilter.texelSpacingMultiplier = 5;
    blurFilter.blurRadiusInPixels = 5;
    
    [self addFilter:blurFilter];
}

- (IBAction)onSketch:(id)sender {
    GPUImageSketchFilter* sketchFilter = [[GPUImageSketchFilter alloc]init];
    [self addFilter:sketchFilter];
}

- (IBAction)onToon:(id)sender {
    GPUImageToonFilter* toonFilter = [[GPUImageToonFilter alloc]init];
    [self addFilter:toonFilter];
}

- (IBAction)onEmboss:(id)sender {
    GPUImageEmbossFilter* embossFilter = [[GPUImageEmbossFilter alloc]init];
    [self addFilter:embossFilter];
}

- (IBAction)onMutiple:(id)sender {
    // 1.创建滤镜组（用于存放各种滤镜：美白、磨皮等等）
    GPUImageFilterGroup* group = [[GPUImageFilterGroup alloc]init];
    
    // 2.创建滤镜(设置滤镜的引用关系，链式调度)
    GPUImageSketchFilter* sketchFilter = [[GPUImageSketchFilter alloc]init];
    GPUImageToonFilter* toonFilter = [[GPUImageToonFilter alloc]init];
    GPUImageEmbossFilter* embossFilter = [[GPUImageEmbossFilter alloc]init];
    
    [sketchFilter addTarget:toonFilter];
    [toonFilter addTarget:embossFilter];
    
    // 3.设置滤镜组链初始&终点的filter
    group.initialFilters = @[sketchFilter];
    group.terminalFilter = embossFilter;
    
    UIImage *sourceImage = [UIImage imageNamed:@"liuyifei"];
    GPUImagePicture* process = [[GPUImagePicture alloc]initWithImage:sourceImage];
    [process addTarget:group];
    [group useNextFrameForImageCapture];
    [process processImage];
    UIImage* distImage = [group imageFromCurrentFramebuffer];
    self.imageView.image = distImage;
}

- (void)addFilter:(GPUImageFilter*)filter {
    // 1.获取待修改的图片
    UIImage *sourceImage = [UIImage imageNamed:@"liuyifei"];
    
    // 2.使用GPUImage高斯模糊效果
    // 2.1.对图像进行处理使用GPUImagePicture
    GPUImagePicture* process = [[GPUImagePicture alloc]initWithImage:sourceImage];
    
    // 2.2部分抽离出来
    // 2.3.把滤镜添加进GPUImagePicture
    [process addTarget:filter];
    
    // 2.4.处理图片
    [filter useNextFrameForImageCapture];
    [process processImage];
    
    // 2.5.取出最新的图片
    UIImage* distImage = [filter imageFromCurrentFramebuffer];
    
    // 3.显示最新的图片
    self.imageView.image = distImage;
}


@end
