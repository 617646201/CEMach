//
//  CEViewController.m
//  CEMach
//
//  Created by zhiyong on 04/28/2022.
//  Copyright (c) 2022 zhiyong. All rights reserved.
//

#import "CEViewController.h"
#import "CEMach.h"

@interface CEViewController ()

@end

@implementation CEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [CEMach appMd5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
