//
//  ClockListView.m
//  TheOlder
//
//  Created by 崔先生的MacBook Pro on 2025/4/25.
//

#import "ClockListView.h"

@interface ClockListView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<ClockViewCell *> *cellArray;
//@property (nonatomic, strong) NSMutableSet<ClockViewCell *> *reusableCells;
@property (nonatomic, assign) NSInteger rowCount;
@property (nonatomic, assign) NSInteger cellIndex;
@property (nonatomic, strong) UIButton *addBtn;

@end

@implementation ClockListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.rowCount = 0;
        self.cellHeight = 96;
        self.cellSpacing = 20;
        self.addButtonHeight = 50;
        self.isShowAddButton = YES;
//        self.reusableCells = [NSMutableSet set];
        [self config];
    }
    return self;
}

- (ClockViewCell *)dequeueCell {
    ClockViewCell *cell = self.cellArray[self.cellIndex];
    return cell;
}


// 提供重用 cell,暂未实现
//- (ClockViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
//    ClockViewCell *cell = [self.reusableCells anyObject];
//    if (cell) {
//        [self.reusableCells removeObject:cell];
//    } else {
//        cell = [[ClockViewCell alloc] initWithReuseIdentifier:identifier];
//    }
//    return cell;
//}

- (void)config {
    if ([self.delegate respondsToSelector:@selector(numberOfCellsInClockListView:)]) {
        self.rowCount = [self.delegate numberOfCellsInClockListView:self];
        [self initView];
    }
}

- (void)initView {
    self.cellArray = [NSMutableArray array];

    for (int i = 0; i < self.rowCount; i++) {
        ClockViewCell *cell = [[ClockViewCell alloc] initWithFrame:CGRectMake(0, (self.cellSpacing + self.cellHeight) * i, self.bounds.size.width, self.cellHeight)];
        [cell configureWithTime:@"10:21" repeat:@"周一 周二" on:YES];
        [self.scrollView addSubview:cell];
        [self.cellArray addObject:cell];

        __weak typeof(self) weakSelf = self;
        cell.deleteBlock = ^(ClockViewCell *cell) {
            NSInteger index = [weakSelf.cellArray indexOfObject:cell];
            [weakSelf deleteCellAtIndex:index];
        };
        
        cell.switchBlock = ^(ClockViewCell *cell, BOOL on) {
            // 处理开关状态变化
            NSInteger index = [weakSelf.cellArray indexOfObject:cell];
            if ([weakSelf.delegate respondsToSelector:@selector(clockListView:didSwitchClockAtIndex:on:)]) {
                [weakSelf.delegate clockListView:weakSelf didSwitchClockAtIndex:index on:on];
            }
        };
        
        cell.tapBlock = ^(ClockViewCell *cell) {
            // 处理点击事件
            [weakSelf cellTapActoin:cell];
        };
        
        cell.panBlock = ^(ClockViewCell *cell) {
            // 处理滑动手势
            [weakSelf closeAllExcept:cell];
        };
        
        if ([self.delegate respondsToSelector:@selector(clockListView:cellForRowAtIndex:)]) {
            self.cellIndex = i;
            [self.delegate clockListView:self cellForRowAtIndex:i];
        }
    }
    
    if (self.isShowAddButton) {
        self.scrollView.contentSize = CGSizeMake(self.bounds.size.width, (self.cellSpacing + self.cellHeight) * self.cellArray.count + self.addButtonHeight);
        [self addBtn];
    } else {
        self.scrollView.contentSize = CGSizeMake(self.bounds.size.width, (self.cellSpacing + self.cellHeight) * self.cellArray.count);
    }
}

- (void)reloadData {
    // 清空之前的 cell
    for (ClockViewCell *cell in self.cellArray) {
//        [self.reusableCells addObject:cell];
        [cell removeFromSuperview];
    }
    [self.cellArray removeAllObjects];

    // 重新加载数据
    [self config];
}

#pragma mark - UIScollerView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self closeAllSwipeCells];
}

#pragma mark - methods

/// 删除 cell
/// - Parameter index: cell 的索引
- (void)deleteCellAtIndex:(NSInteger)index {
    if (index >= self.cellArray.count) return;
    // 判断最后一个 cell 是否可见
    BOOL isLastCellVisible = [self isLastCellVisible];
    NSInteger count = self.cellArray.count;
    ClockViewCell *cellToDelete = self.cellArray[index];
    
    // 移除数据源
    [self.cellArray removeObjectAtIndex:index];
    
    // 更新后续 cell 的位置,如果cell不是最后一个,后面的cell要实现上移
    for (NSInteger i = index; i < count - 1; i++) {
        ClockViewCell *cell = self.cellArray[i];
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            CGRect frame = cell.frame;
            frame.origin.y -= (self.cellHeight + self.cellSpacing);
            cell.frame = frame;
        } completion:nil];
    }

    // 淡出动画
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        cellToDelete.alpha = 0.0;
        if (self.isShowAddButton) {
            self.addBtn.frame = CGRectMake(60, self.scrollView.contentSize.height - self.addButtonHeight - (self.cellHeight + self.cellSpacing), self.bounds.size.width - 120, self.addButtonHeight);
        } else {
            //当cell为最后一项时
            if (index == count - 1) {
                CGRect frame = cellToDelete.frame;
                frame.origin.y += self.cellHeight;
                cellToDelete.frame = frame;
            }
        }
    } completion:^(BOOL finished) {
        [cellToDelete removeFromSuperview];
        
        // 判断最后一个cell是否可见,如果最后一个cell可见,当删除任意一个cell时,底部会出现空虚,contentsize变化时会导致画面突然往下坠,所以先滚到视图最下面再修改contentSize
        if (isLastCellVisible) {
            //删除的是最后一个cell
            CGFloat offsetY = MAX(self.scrollView.contentSize.height - self.scrollView.bounds.size.height - (self.cellSpacing + self.cellHeight), 0);
            [self.scrollView setContentOffset:CGPointMake(0, offsetY) animated:YES];
            //延迟0.3秒,这里延迟0.3秒是为了让动画完成后再更新 contentSize
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self reloadContentSize:count];
            });
        } else {
            [self reloadContentSize:count];
        }
    }];

    // 通知代理
    if ([self.delegate respondsToSelector:@selector(clockListView:didDeleteClockAtIndex:)]) {
        [self.delegate clockListView:self didDeleteClockAtIndex:index];
    }
}

/// 更新 contentSize
/// - Parameter count: cell 数量
- (void)reloadContentSize:(NSInteger)count {
    if (self.isShowAddButton) {
        self.scrollView.contentSize = CGSizeMake(self.bounds.size.width, (self.cellSpacing + self.cellHeight) * (count - 1) + self.addButtonHeight);
    } else {
        self.scrollView.contentSize = CGSizeMake(self.bounds.size.width, (self.cellSpacing + self.cellHeight) * (count - 1));
    }
}

/// 是否最后一个 cell 可见
- (BOOL)isLastCellVisible {
    if (self.cellArray.count == 0) return NO;

    ClockViewCell *lastCell = self.cellArray.lastObject;
    CGRect cellFrameInScrollView = lastCell.frame;
    CGRect visibleRect = CGRectMake(self.scrollView.contentOffset.x,
                                    self.scrollView.contentOffset.y,
                                    self.scrollView.bounds.size.width,
                                    self.scrollView.bounds.size.height);

    return CGRectIntersectsRect(cellFrameInScrollView, visibleRect);
}

- (void)closeAllExcept:(ClockViewCell *)exceptCell {
    for (ClockViewCell *cell in self.cellArray) {
        if (cell != exceptCell) {
            [cell closeSwipe];
        }
    }
}

- (void)closeAllSwipeCells {
    for (ClockViewCell *cell in self.cellArray) {
        if (cell.isOpen) {
            [cell closeSwipe];
        }
    }
}

- (void)cellTapActoin:(ClockViewCell *)currentCell {
    if (currentCell.isOpen) {
        [currentCell closeSwipe];
        return;
    }
    
    // 检查是否有其他 cell 是打开的
    BOOL isOpen = NO;
    for (ClockViewCell *cell in self.cellArray) {
        if (cell != currentCell && cell.isOpen) {
            isOpen = YES;
            break;
        }
    }
    
    // 如果没有其他 cell 是打开的，执行点击事件,否则关闭其他 cell
    if (isOpen) {
        [self closeAllExcept:currentCell];
    } else {
        // 通知代理
        if ([self.delegate respondsToSelector:@selector(clockListView:didClickClockAtIndex:)]) {
            NSInteger index = [self.cellArray indexOfObject:currentCell];
            if (index != NSNotFound) {
                [self.delegate clockListView:self didClickClockAtIndex:index];
            }
        }
    }
}

- (void)addClockAction {
    // 处理添加按钮点击事件
    if ([self.delegate respondsToSelector:@selector(clockListViewDidClickAddButton:)]) {
        [self.delegate clockListViewDidClickAddButton:self];
    }
}

#pragma mark - lazy load

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _scrollView.backgroundColor = [UIColor colorWithRed:242/255.0 green:243/255.0 blue:245/255.0 alpha:1.0];;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIButton *)addBtn {
    if (!_addBtn) {
        _addBtn = [[UIButton alloc] initWithFrame:CGRectMake(60, self.scrollView.contentSize.height - self.addButtonHeight, self.bounds.size.width - 120, self.addButtonHeight)];
        _addBtn.backgroundColor = [UIColor clearColor];
        [_addBtn setImage:[UIImage imageNamed:@"AddClock_icon"] forState:UIControlStateNormal];
        [_addBtn addTarget:self action:@selector(addClockAction) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:_addBtn];
    }
    return _addBtn;
}

@end
