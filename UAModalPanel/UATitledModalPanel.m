//
//  UAModalTitledDisplayPanelView.m
//  Flipped Text
//
//  Created by Matt Coneybeare on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UATitledModalPanel.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_TITLE_BAR_HEIGHT	40.0f

@implementation UATitledModalPanel

@synthesize titleBarHeight, titleBar, headerLabel;

- (void)dealloc {
    self.titleBar = nil;
	self.headerLabel = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
       
		self.titleBarHeight = DEFAULT_TITLE_BAR_HEIGHT;
		
		actualTitleBar = [[UIView alloc] initWithFrame:CGRectZero];
        [self.roundedRect addSubview:actualTitleBar];
		
		self.headerLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		self.headerLabel.font = [UIFont systemFontOfSize:24];
		self.headerLabel.backgroundColor = [UIColor clearColor];
		self.headerLabel.textColor = [UIColor whiteColor];
		self.headerLabel.shadowColor = [UIColor blackColor];
		self.headerLabel.shadowOffset = CGSizeMake(0, -1);
		self.headerLabel.textAlignment = UITextAlignmentCenter;
		[actualTitleBar addSubview:self.headerLabel];
    }
    return self;
}

- (void)setTitleBar:(UIView *)newTitleBar {
    if (titleBar != nil) {
        [titleBar removeFromSuperview];
    }
    
    titleBar = newTitleBar;
    [actualTitleBar insertSubview:newTitleBar atIndex:0];
    [self setNeedsLayout];
}

- (UIView*)titleBar {
    if (titleBar == nil) {
        CGFloat colors[8] = { 1, 1, 1, 1, 0, 0, 0, 1 };
		self.titleBar = [UANoisyGradientBackground gradientWithFrame:CGRectZero
															   style:UAGradientBackgroundStyleLinear
															   color:colors
															lineMode:UAGradientLineModeTopAndBottom
														noiseOpacity:0.2
														   blendMode:kCGBlendModeNormal];
        [actualTitleBar addSubview:self.titleBar];
    }
    
    return titleBar;
}


- (CGRect)titleBarFrame { 
	CGRect frame = [self.roundedRect bounds];
	return CGRectMake(frame.origin.x,
					  frame.origin.y + self.roundedRect.layer.borderWidth,
					  frame.size.width,
					  self.titleBarHeight + self.innerMargin);
}

// Overrides

- (CGRect)contentViewFrame {
    // we don't inset the top margin
    CGRect rect = [self roundedRectFrame];
	rect = CGRectMake(rect.origin.x - self.innerMargin, rect.origin.y, rect.size.width - self.innerMargin * 2, rect.size.height - self.innerMargin);
    return rect;
}



- (void)layoutSubviews {
	[super layoutSubviews];
	
    CGRect frame = self.roundedRect.frame;
    frame.origin.y -= self.titleBarHeight;
    frame.size.height += self.titleBarHeight;
    self.roundedRect.frame = frame;
    
    actualTitleBar.frame = [self titleBarFrame];
    self.titleBar.frame = actualTitleBar.bounds;
	self.headerLabel.frame = actualTitleBar.bounds;
    
    self.closeButton.frame = [self closeButtonFrame];
}



@end
