//
//  ClockListView.h
//  TheOlder
//
//  Created by 崔先生的MacBook Pro on 2025/4/25.
//

#import <UIKit/UIKit.h>
#import "ClockViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class ClockListView;

@protocol ClockListViewDelegate <NSObject>

@optional
/// 删除cell的回调
/// - Parameters:
///   - clockListView: clockListView
///   - index: index
- (void)clockListView:(ClockListView *)clockListView didDeleteClockAtIndex:(NSInteger)index;

@optional
/// 点击cell的回调
/// - Parameters:
///   - clockListView: clockListView
///   - index: index
- (void)clockListView:(ClockListView *)clockListView didClickClockAtIndex:(NSInteger)index;

@optional
- (void)clockListView:(ClockListView *)clockListView didSwitchClockAtIndex:(NSInteger)index on:(BOOL)on;

@optional
/// 添加按钮的回调
/// - Parameter clockListView: clockListView
- (void)clockListViewDidClickAddButton:(ClockListView *)clockListView;

/// 设置cell的样式
/// - Parameters:
///   - clockListView: clockListView
///   - index: index
- (ClockViewCell *)clockListView:(ClockListView *)clockListView cellForRowAtIndex:(NSInteger)index;


/// 设置cell的个数
/// - Parameter clockListView: clockListView
- (NSInteger)numberOfCellsInClockListView:(ClockListView *)clockListView;


@end

@interface ClockListView : UIView

/// 代理
@property (nonatomic, weak) id<ClockListViewDelegate> delegate;
/// cell的高度
@property (nonatomic, assign) CGFloat cellHeight;
/// 每个cell之间的间距
@property (nonatomic, assign) CGFloat cellSpacing;
/// 是否展示添加按钮
@property (nonatomic, assign) BOOL isShowAddButton;
/// 添加按钮的高度
@property (nonatomic, assign) CGFloat addButtonHeight;


- (ClockViewCell *)dequeueCell;
//- (ClockViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
