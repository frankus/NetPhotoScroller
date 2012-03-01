# NetPhotoScroller

This is a variation on Apple's [PhotoScroller sample app](http://developer.apple.com/library/ios/samplecode/PhotoScroller/) that loads the tiles over a network connection rather than storing them locally. 

Unfortunately it requires use of a couple of undocumented methods on CATiledLayer that would prevent you from deploying it to the App Store. 

You can use it in your own internal ad-hoc apps and possibly (with the obvious modifications) for Mac apps not distributed through the Mac App Store. 

Because this code demonstrates the impossibility of fetching tiles asynchronously in a CATiledLayer, my hope is that I can get a few more
developers to file duplicate bug reports at http://bugreport.apple.com/ to "vote" for publishing the required APIs. 

The tiles are hosted on my personal account. If you plan to do any heavy testing or (God forbid) distribution of this example, please [download
the original project from Apple](https://developer.apple.com/library/ios/samplecode/PhotoScroller/PhotoScroller.zip) and host a copy of the images
on your own server. 

### Dependency

This project incorporates the excellent [AFNetworking](https://github.com/AFNetworking/AFNetworking) project as a submodule. Once you have cloned the project,
run `git submodule init && git submodule update` to pull down a copy into your project.  

## The Problem

In a `CATiledLayer`, any time you return from `-drawRect:` or `-drawLayer:inContext:` without having drawn anything, the tile (previously containing a blurry zoomed-in version of the previous content) is replaced by solid black. This is somewhat jarring. 

One solution is to use a blocking network call inside of these methods to fetch a tile over the net, but the OS only fetches one tile at a time, so you're limited to one concurrent network request. The performance is abysmal. 

### The Solution

`CATiledLayer` has a couple of undocumented methods. The first is `-canDrawRect:levelOfDetail:`, which lets you tell the layer whether or not a tile has been loaded, and serves as a hint that you should start downloading it. The second is `-setNeedsDisplayInRect:levelOfDetail:` which lets you tell the layer that you've finished downloading the tile (for a particular rectangular region and level of detail) and that it should go ahead and call one of the drawing methods. 

## Half-baked Areas

- LSNetTiledLayerDataSource is a singleton, whereas it should probably be passed down the chain from the app delegate to the view
- The call to grab the image metadata is blocking. It should be done asynchronously. 
- There seem to be some drawing glitches where CATiledLayer is displaying invalid cached tiles

## License

My modifications are licensed under Creative Commons [by attribution](http://creativecommons.org/licenses/by/3.0/) (CC BY 3.0), with the following disclaimer courtesy of MIT:

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Here is Apple's original license/disclaimer:

Disclaimer: IMPORTANT: This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms. If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple. Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis. APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2010 Apple Inc. All Rights Reserved.