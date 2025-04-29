//
//  ViewController.m
//  ClockView
//
//  Created by 崔先生的MacBook Pro on 2025/4/29.
//

#import "ViewController.h"
#import "ClockView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:243/255.0 blue:245/255.0 alpha:1.0];
    [self initView];
}

- (void)initView {
    ClockView *clockView = [[ClockView alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width, self.view.bounds.size.height - 80)];
    clockView.backgroundColor = [UIColor colorWithRed:242/255.0 green:243/255.0 blue:245/255.0 alpha:1.0];
    [self.view addSubview:clockView];
}


@end
