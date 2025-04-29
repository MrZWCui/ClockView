//
//  ClockView.m
//  TheOlder
//
//  Created by 崔先生的MacBook Pro on 2025/4/24.
//

#import "ClockView.h"
#import "ClockViewCell.h"
#import "ClockListView.h"

@interface ClockView () <ClockListViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) ClockListView *listView;

@end

@implementation ClockView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.bounds.size.width - 40, 52)];
    topLabel.text = @"     ⁨⁩ 当到达所设置的时间，智能床将缓缓升起，帮你从梦中唤醒。";
    topLabel.textColor = [UIColor colorWithRed:111/255.0 green:111/255.0 blue:111/255.0 alpha:1.0];;
    topLabel.font = [UIFont systemFontOfSize:18];
    topLabel.textAlignment = NSTextAlignmentLeft;
    topLabel.numberOfLines = 0;
    [self addSubview:topLabel];
    
    [self addSubview:self.listView];
    [self reloadData];
}

- (void)reloadData {
    self.dataArray = [NSMutableArray array];
    // Example data loading
    for (int i = 0; i < 10; i++) {
        [self.dataArray addObject:@(i)];
    }
    [self.listView reloadData];
}

#pragma mark - delegate

- (NSInteger)numberOfCellsInClockListView:(ClockListView *)clockListView {
    return self.dataArray.count;
}

- (ClockViewCell *)clockListView:(ClockListView *)clockListView cellForRowAtIndex:(NSInteger)index {
//    ClockViewCell *cell = [clockListView dequeueReusableCellWithIdentifier:@"ClockCell"];
    ClockViewCell *cell = [clockListView dequeueCell];
    NSString *time = [NSString stringWithFormat:@"10:%02ld", index];
    [cell configureWithTime:time repeat:@"周一 周二" on:YES];
    return cell;
}

- (void)clockListView:(ClockListView *)clockListView didDeleteClockAtIndex:(NSInteger)index {
    [self.dataArray removeObjectAtIndex:index];
//    [clockListView reloadData];
}

- (void)clockListView:(ClockListView *)clockListView didClickClockAtIndex:(NSInteger)index {
    // Handle clock click event
    NSLog(@"Clock at index %ld clicked", (long)index);
}

- (void)clockListView:(ClockListView *)clockListView didSwitchClockAtIndex:(NSInteger)index on:(BOOL)on {
    // Handle switch state change
    NSLog(@"Clock at index %ld switched %@", (long)index, on ? @"ON" : @"OFF");
}

#pragma mark - lazy load

- (ClockListView *)listView {
    if (!_listView) {
        _listView = [[ClockListView alloc] initWithFrame:CGRectMake(0, 72, self.bounds.size.width, self.bounds.size.height - 72)];
        _listView.backgroundColor = [UIColor colorWithRed:242/255.0 green:243/255.0 blue:245/255.0 alpha:1.0];;
        _listView.delegate = self;
        _listView.cellHeight = 96;//96
        _listView.cellSpacing = 20;//20
    }
    return _listView;
}

@end
