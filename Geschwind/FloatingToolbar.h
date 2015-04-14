//
//  FloatingToolbar.h
//  Geschwind
//
//  Created by Beni Cheni on 4/13/15.
//  Copyright (c) 2015 Princess of Darkness Factory. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FloatingToolbar;

@protocol FloatingToolbarDelegate <NSObject>

@optional

- (void)floatingToolbar:(FloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title;

@end

@interface FloatingToolbar : UIView

@property (nonatomic, weak)id <FloatingToolbarDelegate> delegate;

- (instancetype)initWithFourTitles:(NSArray *)titles;
- (void)setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end
