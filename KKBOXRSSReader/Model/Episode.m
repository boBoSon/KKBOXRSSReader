//
//  Episode.m
//  KKBOXRSSReader
//
//  Created by CHIU PO-SHENG on 2021/1/18.
//

#import "Episode.h"

@implementation Episode

@synthesize content = _content;

- (id)initWithTitle:(NSString *)newTitle contentURL:(NSURL *)newContentURL publishedDate:(NSDate *)pubDate imageURL:(NSURL *)imgURL description:(NSString *)desc {
    if (!(self = [super init])) {
        return nil;
    }
    _title = newTitle;
    _contentURL = newContentURL;
    publishedDate = pubDate;
    _imgURL = imgURL;
    _desc = desc;
    
    return self;
}

- (NSString *)pubDateString {
    static dispatch_once_t once;
    static NSDateFormatter *formatter;

    dispatch_once(&once, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy/MM/dd";
    });
    
    return [formatter stringFromDate:publishedDate];
}


@end
