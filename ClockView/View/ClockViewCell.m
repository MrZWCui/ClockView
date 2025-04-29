//
//  ClockViewCell.m
//  TheOlder
//
//  Created by 崔先生的MacBook Pro on 2025/4/24.
//

#import "ClockViewCell.h"

@interface ClockViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGFloat contentViewX;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *repeatLabel;
@property (nonatomic, strong) UISwitch *switchView;
@property (nonatomic, strong) UIButton *deleteBtn;

@end

@implementation ClockViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isOpen = NO;
        [self initView];
        [self addGesture];
    }
    return self;
}

//- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
//    if (self = [super initWithFrame:CGRectZero]) {
//        _reuseIdentifier = [reuseIdentifier copy];
//        // 在这里加 subviews
//        
//        self.isOpen = NO;
//        [self initView];
//        [self addGesture];
//    }
//    return self;
//}

- (void)addGesture {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.cancelsTouchesInView = NO;
    pan.delegate = self;
    [self.contentView addGestureRecognizer:pan];
    
    //点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.contentView addGestureRecognizer:tap];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint translation = [pan translationInView:self];
        return fabs(translation.x) > fabs(translation.y); // 横向滑动才触发 cell 滑动
    }
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    if (self.isOpen) {
        [self closeSwipe];
        return;
    }
    if (self.tapBlock) {
        self.tapBlock(self);
    }
}

#pragma mark - 手势处理

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    if (self.panBlock) {
        self.panBlock(self);
    }
    CGPoint translation = [gesture translationInView:self];
    
    static CGFloat originalX = 0;
    static CGFloat originalXOfBtn = 0;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        originalX = self.contentView.frame.origin.x;// 记录初始位置
        originalXOfBtn = self.deleteBtn.frame.origin.x;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat newX = 0;
        CGFloat effectWidth = 0;//为了让按钮多一个滑动过多时的回弹效果,显得不那么生硬,根据具体需要增加
        
        if (originalX == self.contentViewX) {
            // 如果初始位置为self.contentViewX，则允许向左滑动
            newX = MIN(0 + effectWidth, MAX(-76 - effectWidth, translation.x));// 限制左滑范围默认 0 到 -76
        } else {
            newX = MIN(76 + effectWidth, MAX(0 - effectWidth, translation.x));// 限制左滑范围默认 0 到 76
        }
        
        self.contentView.frame = CGRectMake(newX + originalX, 0, self.bounds.size.width - 40, self.bounds.size.height);
        
        if (self.isFollowing) {
            self.deleteBtn.frame = CGRectMake(originalXOfBtn + newX, 0, 70, self.bounds.size.height);
        }
        
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        CGFloat threshold = -38 + self.contentViewX; // 触发删除按钮的阈值
        // 滑动超过一半，固定显示全部按钮
        if (self.contentView.frame.origin.x < threshold) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.contentView.frame = CGRectMake(-56, 0, self.bounds.size.width - 40, self.bounds.size.height);
                if (self.isFollowing) {
                    self.deleteBtn.frame = CGRectMake(self.bgView.bounds.size.width - 70, 0, 70, self.bounds.size.height);
                }
            } completion:^(BOOL finished) {
                self.isOpen = YES;
            }];
        } else {
            // 否则弹回
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.contentView.frame = CGRectMake(20, 0, self.bounds.size.width - 40, self.bounds.size.height);
                if (self.isFollowing) {
                    self.deleteBtn.frame = CGRectMake(self.bgView.bounds.size.width + 6, 0, 70, self.bounds.size.height);
                }
            } completion:^(BOOL finished) {
                self.isOpen = NO;
            }];
        }
    }
}

- (void)initView {
    self.contentViewX = 20;
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width - 20, self.bounds.size.height)];
    self.bgView.layer.masksToBounds = YES;
    [self addSubview:self.bgView];
    
    self.deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bgView.bounds.size.width - 70, 0, 70, self.bounds.size.height)];
    [self.deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    self.deleteBtn.layer.cornerRadius = 15;
    self.deleteBtn.layer.masksToBounds = YES;
    [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [self.deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.deleteBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    self.deleteBtn.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];;
    [self.bgView addSubview:self.deleteBtn];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(self.contentViewX, 0, self.bgView.bounds.size.width - self.contentViewX, self.bounds.size.height)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 15;
    self.contentView.layer.masksToBounds = YES;
    [self.bgView addSubview:self.contentView];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 16, 100, 30)];
    self.timeLabel.font = [UIFont systemFontOfSize:20];
    self.timeLabel.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];;
    [self.contentView addSubview:self.timeLabel];
    
    self.repeatLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 59, 300, 25)];
    self.repeatLabel.font = [UIFont systemFontOfSize:16];
    self.repeatLabel.textColor = [UIColor colorWithRed:111/255.0 green:111/255.0 blue:111/255.0 alpha:1.0];;
    [self.contentView addSubview:self.repeatLabel];
    
    self.switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.switchView.center = CGPointMake(self.contentView.bounds.size.width - 45, 30);
    self.switchView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.switchView.onTintColor = [UIColor colorWithRed:56/255.0 green:255/255.0 blue:209/255.0 alpha:1.0];;
    [self.contentView addSubview:self.switchView];
    [self.switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    self.isFollowing = YES;
}

- (void)deleteAction:(UIButton *)sender {
    if (self.deleteBlock) {
        self.deleteBlock(self);
    }
}

- (void)switchAction:(UISwitch *)sender {
    if (self.switchBlock) {
        self.switchBlock(self, sender.isOn);
    }
}

#pragma mark - reload

- (void)configureWithTime:(NSString *)time repeat:(NSString *)repeat on:(BOOL)on {
    self.timeLabel.text = time;
    self.repeatLabel.text = repeat;
    [self.switchView setOn:on animated:NO];
}

- (void)closeSwipe {
    if (!self.isOpen) return;
    self.isOpen = NO;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentView.frame = CGRectMake(20, 0, self.bounds.size.width - 40, self.bounds.size.height);
        if (self.isFollowing) {
            self.deleteBtn.frame = CGRectMake(self.bgView.bounds.size.width + 6, 0, 70, self.bounds.size.height);
        }
    } completion:^(BOOL finished) {}];
}

#pragma mark - lazy load and setters

- (void)setIsFollowing:(BOOL)isFollowing {
    _isFollowing = isFollowing;
    if (isFollowing) {
        self.deleteBtn.frame = CGRectMake(self.bgView.bounds.size.width + 6, 0, 70, self.bounds.size.height);
    } else {
        //宽度高度缩小,上右下缩小1,因为Core Animation 的“抗锯齿边缘融合”问题（subpixel blending）,圆角边缘的半透明像素会“透”出红色
        self.deleteBtn.frame = CGRectMake(self.bgView.bounds.size.width - 70, 1, 69, self.bounds.size.height - 2);
    }
}

@end
