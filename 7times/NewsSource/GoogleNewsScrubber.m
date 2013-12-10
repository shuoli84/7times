//
// Created by Li Shuo on 13-11-29.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import "GoogleNewsScrubber.h"


@implementation GoogleNewsScrubber {

}

-(NSString*)scrubTitle:(NSString *)title {
    //strip title's source out
    NSRange range = [title rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"-"] options:NSBackwardsSearch];

    if(range.location != NSNotFound){
        title = [title substringWithRange:NSMakeRange(0, range.location)];
    }

    return title;
}

-(NSString*)scrubContent:(NSString*)content{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
        @"<td.*?>(.*?)</td>" options:0 error:nil];
    NSArray *matches = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    if(matches.count >= 1){
        NSTextCheckingResult *match = matches[matches.count - 1];
        NSRange range = [match rangeAtIndex:match.numberOfRanges-1];
        content = [content substringWithRange:range];
        
    }

    content = [content stringByReplacingOccurrencesOfString:@"<div style=\"padding-top:0.8em;\">" withString:@""];

    NSRegularExpression *stripAddMore = [NSRegularExpression regularExpressionWithPattern:@"(<a.*?/a>)" options:0 error:nil];

    content = [stripAddMore stringByReplacingMatchesInString:content options:0 range:NSMakeRange(0, content.length) withTemplate:@""];

    NSRegularExpression *nobr = [NSRegularExpression regularExpressionWithPattern:@"(<nobr.*?nobr>)" options:0 error:nil];
    content = [nobr stringByReplacingMatchesInString:content options:0 range:NSMakeRange(0, content.length) withTemplate:@""];
    
    NSRegularExpression *font = [NSRegularExpression regularExpressionWithPattern:@"<div class=\"lh\">(<br />)*(.*)</div>" options:0 error:nil];
    matches = [font matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    
    if (matches.count >= 1){
        NSTextCheckingResult *match = matches[matches.count - 1];
        content = [content substringWithRange:
                   [match rangeAtIndex:match.numberOfRanges - 1]];
    }

    return content;
}
@end