//
//  ClockViewCell.h
//  TheOlder
//
//  Created by 崔先生的MacBook Pro on 2025/4/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ClockViewCell : UIView

/// 更新cell数据
/// - Parameters:
///   - time: 时间
///   - repeat: 重复日期
///   - on: 开关状态
- (void)configureWithTime:(NSString *)time repeat:(NSString *)repeat on:(BOOL)on;

/// 删除按钮是否跟随视图滑动,默认YES
@property (nonatomic, assign) BOOL isFollowing;
/// 是否为打开状态,默认NO
@property (nonatomic, assign) BOOL isOpen;

/// cell的高度
@property (nonatomic, assign) CGFloat cellHeight;
/// 每个cell之间的间距
@property (nonatomic, assign) CGFloat cellSpacing;

//- (void)openSwipe;
/// 恢复视图位置
- (void)closeSwipe;

//@property (nonatomic, copy, readonly) NSString *reuseIdentifier;

//- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, copy) void(^deleteBlock)(ClockViewCell *cell);
@property (nonatomic, copy) void(^switchBlock)(ClockViewCell *cell, BOOL on);
@property (nonatomic, copy) void(^tapBlock)(ClockViewCell *cell);
@property (nonatomic, copy) void(^panBlock)(ClockViewCell *cell);

@end

NS_ASSUME_NONNULL_END
