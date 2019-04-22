//
//  ViewController.m
//  BeautyCamera
//
//  Created by zhaoliang chen on 2019/4/22.
//  Copyright © 2019 zhaoliang chen. All rights reserved.
//

#import "ViewController.h"
#import "PhotoViewController.h"
#import "CameraViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onPhoto:(id)sender {
    [self.navigationController pushViewController:[[PhotoViewController alloc]init] animated:YES];
}

- (IBAction)onCamera:(id)sender {
    [self.navigationController pushViewController:[[CameraViewController alloc]init] animated:YES];
}

@end
