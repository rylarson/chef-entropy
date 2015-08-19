# entropy cookbook

This cookbook will install an entropy gathering daemon on lots of different platforms.

Applications can hang or become very slow due to lack of entropy, especially when generating
keys (like RSA or GPG keys). Installing an entropy gathering daemon gives the OS a relatively 
high quality source of entropy.

## Entropy daemons

### haveged 

Right now, this cookbook only supports install haveged. This is an entropy gathering daemon that
I have a lot of experience with and that is well supported on lots of platforms. I am totally open
to implementing recipes for other entropy gathering daemons as well.

## Supported Platforms

See [metadata.rb](metadata.rb) for the list of supported platforms

## Usage

This cookbook is available on the public supermarket.

Depend on the `entropy` cookbook in your cookbook's metadata.rb file
 
`depends 'entropy'`

### default recipe

Add the default recipe to your run list

`recipe[entropy]`

This will install an entropy gathering daemon for your platform (if supported).

## License and Authors

Author:: Ryan Larson (ryan.mango.larson@gmail.com)
