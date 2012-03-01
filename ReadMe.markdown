# NetPhotoScroller

This is a variation on Apple's [PhotoScroller sample app](http://developer.apple.com/library/ios/samplecode/PhotoScroller/) that loads the tiles over a network connection rather than storing them locally. 

Unfortunately it requires use of a couple of undocumented methods on CATiledLayer that would prevent you from deploying it to the App Store. 

You can use it in your own internal ad-hoc apps and possibly (with the obvious modifications) for Mac apps not distributed through the Mac App Store. 

Because this code demonstrates the impossibility of fetching tiles asynchronously in a CATiledLayer, my hope is that I can get a few more
developers to file duplicate bug reports at http://bugreport.apple.com/ to "vote" for publishing the required APIs. 

The tiles are hosted on my personal account. If you plan to do any heavy testing or (God forbid) distribution of this example, please [download
the original project from Apple](https://developer.apple.com/library/ios/samplecode/PhotoScroller/PhotoScroller.zip) and host a copy of the images
on your own server. 

## Dependency

This project incorporates the excellent [AFNetworking](https://github.com/AFNetworking/AFNetworking) project as a submodule. Once you have cloned the project,
run `git submodule init && git submodule update` to pull down a copy into your project.  

## How It Works

