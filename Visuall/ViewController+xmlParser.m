//
//  ViewController+xmlParser.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 9/1/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "ViewController+xmlParser.h"
#import "DDFileReader.h"
#import "RegExCategories.h"

@implementation ViewController (xmlParser)

- (void) loadAndUploadXML
{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"defaultVisualizationSmall"
                                                         ofType:@"xml"];
    __block NSString *result = @"test";  // https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Blocks/Articles/bxVariables.html
    __block NSString *text;
    DDFileReader * reader = [[DDFileReader alloc] initWithFilePath: filePath];
    [reader enumerateLinesUsingBlock:^(NSString * line, BOOL * stop) {
        result = [result stringByAppendingString: line];
        
        if ([result isMatch:RX(@"\\<node\\sid\\=\"(\\d)+\"\\>")] && [result isMatch:RX(@"\\<\\/node\\>")])
        {
            text = [result firstMatch:RX(@"\\<data key\\=\"name\"\\>[\\s\\S]*?\\<\\/data>")];
            text = [text stringByReplacingOccurrencesOfString:@"<data key=\"name\">" withString:@""];
            text = [text stringByReplacingOccurrencesOfString:@"</data>" withString:@""];
            NSLog(@"read text: \n %@", text);
            result = @"";
        }
    }];
}

@end
