Installing the Base Omnibus Toolchain on Windows 2016/2012
==================

Since Windows is not a GNU based toolchain, installing the pre-requisites is somewhat hard. This procedure has been tested on the following platforms: Windows 2016, Windows 2012. Other platforms may work, if they do a PR would be greatly appreciated to include the known platform in the docs and any other changes that may be necessary.

Install a build toolchain for the platform as specified by the [build-essential cookbook](https://github.com/chef-cookbooks/build-essential/blob/master/resources/build_essential.rb)

Install git
---------------
[Download](https://git-scm.com/download/win) and install git for windows

Install Ruby
---------------

[Download](https://rubyinstaller.org/) and install ruby with devkit

Update Windows Path and Environment
---------------
```
Add new windows environment MSYSTEM=MINGW64/MINGW32
Add new windows environment OMNIBUS_WINDOWS_ARCH=x64/x86
Update windows Path, add C:\Ruby25-x64\msys64\usr\bin;C:\Ruby25-x64\msys64\mingw64\bin;C:\Ruby25-x64\bin
```
* Assuming C:\Ruby25-x64 was selected during your ruby installation.

Known Issues 
---------------
Build failed with error:  tar (child): Cannot connect to C: resolve failed
Open C:/Ruby25-x64/lib/ruby/gems/2.5.0/bundler/gems/omnibus-7d00d32d4186/lib/omnibus/fetchers/net_fetcher.rb line 239
and force seven_zip extract (change condition from != to ==)

Install bundler
---------------

```
gem install bundler
```

Download and build omnibus-toolchain
---------------

```
git clone https://github.com/aerobase/omnibus-toolchain.git
cd omnibus-toolchain

# if a Gemfile.lock file already exists then run
bundle install --without development --deployment

# if a Gemfile.lock file does not already exist then run
bundle install --without development --path vendor/bundle

bundle exec omnibus build omnibus-toolchain
```

Once the build is finished the rpm and metadata files should be found in the ./pkg/ directory.

Common Problems
---------------

On some platforms, the ffi rubygem will fail to compile it's native extensions. Most distributions include a version of libffi which has support for your platform, which we install as part of the preconditions above. However, it may be too old for the ffi rubygem. If this is the case, the best course of action is to install the latest version of [libffi](https://sourceware.org/libffi/) attempt to compile it and install it as root. If it's installed and visible via pkg-config then the ffi rubygem will use that instead of the older native code included within it's codebase.
