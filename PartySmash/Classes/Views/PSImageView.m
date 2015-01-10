/*
 *  Copyright (c) 2014, Facebook, Inc. All rights reserved.
 *
 *  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
 *  copy, modify, and distribute this software in source code or binary form for use
 *  in connection with the web services and APIs provided by Facebook.
 *
 *  As with any software that integrates with the Facebook platform, your use of
 *  this software is subject to the Facebook Developer Principles and Policies
 *  [http://developers.facebook.com/policy/]. This copyright notice shall be
 *  included in all copies or substantial portions of the software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 *  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 *  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 *  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 *  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#import "PSImageView.h"

#import <Bolts/BFTaskCompletionSource.h>

#import <Parse/PFFile.h>

#import "PFImageCache.h"

@implementation PSImageView

#pragma mark -
#pragma mark Accessors

- (void)setFile:(PFFile *)otherFile {
    // Here we don't check (file != otherFile)
    // because self.image needs to be updated regardless.
    // setFile: could have altered self.image
    _file = otherFile;
    NSURL *url = [NSURL URLWithString:self.file.url];
    UIImage *cachedImage = [[PFImageCache sharedCache] imageForURL:url];
    if (cachedImage) {
        self.image = cachedImage;
    }
}

#pragma mark -
#pragma mark Load

- (BFTask *)loadInBackground {
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    [self loadInBackground:^(UIImage *image, NSError *error) {
        if (error) {
            [source trySetError:error];
        } else {
            [source trySetResult:image];
        }
    }];
    return source.task;
}

- (void)loadInBackground:(void (^)(UIImage *, NSError *))completion {
    if (!self.file) {
        // When there is nothing to load, the user just wants to display
        // the placeholder image. I think the better design decision is
        // to return with no error, to simplify caller logic. (arguable)
        if (completion) {
            completion(nil, nil);
        }
        return;
    }

    if (!self.file.url) {
        // The file has not been saved.
        if (completion) {
            NSError *error = [NSError errorWithDomain:PFParseErrorDomain code:kPFErrorUnsavedFile userInfo:nil];
            completion(nil, error);
        }
        return;
    }

    NSURL *url = [NSURL URLWithString:self.file.url];
    if (url) {
        UIImage *cachedImage = [[PFImageCache sharedCache] imageForURL:url];
        if (cachedImage) {
            self.image = cachedImage;

            if (completion) {
                completion(cachedImage, nil);
            }
            return;
        }
    }


    PFFile *file = _file;
    [_file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, error);
                });
            }
            return;
        }

        // We dispatch to a background queue to offload the work to decode data into image
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *image = [self getImageWithRoundCorners:[UIImage imageWithData:data] withRect:self.bounds.size];
//            UIImage *image = [UIImage imageWithData:data];
            if (!image) {
                if (completion) {
                    NSError *invalidDataError = [NSError errorWithDomain:PFParseErrorDomain
                                                                    code:kPFErrorInvalidImageData
                                                                userInfo:nil];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil, invalidDataError);
                    });
                }
                return;
            }

            if (file != _file) {
                // a latter issued loadInBackground has replaced the file being loaded
                if (completion) {
                    completion(image, nil);
                }

                return;
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = image;

                if (completion) {
                    completion(image, nil);
                }
            });

            if (url) {
                // We always want to store the image in the cache.
                // In previous checks we've verified neither key nor value is nil.
                [[PFImageCache sharedCache] setImage:image forURL:url];
            }
        });
    }];
}

- (UIImage *)getImageWithRoundCorners:(UIImage *)img withRect:(CGSize) rect {
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(rect, NO, [UIScreen mainScreen].scale);

    // Add a clip before drawing anything, in the shape of an rounded rect
    UIBezierPath *p = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, rect.width, rect.height)];

    [[UIColor colorWithRed:97/255.0 green:36/255.0 blue:99/255.0 alpha:1.0] setStroke];
    [p addClip];

    // Draw your image
    [img drawInRect:CGRectMake(0, 0, rect.width, rect.height)];

    // Get the image, here setting the UIImageView image
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();

    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();

    return result;
}

@end
