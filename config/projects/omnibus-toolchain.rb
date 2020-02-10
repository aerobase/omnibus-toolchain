#
# Copyright 2015-2016, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

name "omnibus-toolchain"
friendly_name "AeroBase Toolchain"
maintainer "Aerobase Software Inc"
homepage   "https://aerobase.io"
license "Apache-2.0"
license_file "LICENSE"

build_iteration 1
# Do not use __FILE__ after this point, use current_file. If you use __FILE__
# after this point, any dependent defs (ex: angry-omnibus-toolchain) that
# use instance_eval will fail to work correctly.
current_file ||= __FILE__
version_file = File.expand_path("../../../VERSION", current_file)
build_version IO.read(version_file).strip

# In order to prevent unecessary cache expiration,
# package and package version overrides, build_version
# and build_iteration are kept in <project-root>/omnibus_overrides.rb
overrides_path = File.expand_path("../../../omnibus_overrides.rb", __FILE__)
instance_eval(IO.read(overrides_path), overrides_path)

if windows?
  install_dir  "#{default_root}/opscode/#{name}"
  package_name "omnibus-toolchain"
else
  install_dir "#{default_root}/#{name}"
end

override :ruby, version: "2.6.3"

# tar 1.32 is not compatible with the Ubuntu 14.04's latest version of dpkg-deb so pin it to 1.28
if ubuntu_trusty?
  override :gtar, version: "1.28"
else
  override :gtar, version: "1.32"
end

# riding berkshelf master is hard when you're at the edge of versions
override :berkshelf, version: "v7.0.8"

# creates required build directories
dependency "preparation"

# Split the toolchain defs into their own software def so we can have
# a custom whitelist
dependency "omnibus-toolchain"

exclude '\.git*'
exclude 'bundler\/git'

package :rpm do
  signing_passphrase ENV["OMNIBUS_RPM_SIGNING_PASSPHRASE"]
end

# This is so that angry-omnibus-toolchain will end up with the correct name
proj_to_work_around_cleanroom = self
package :pkg do
  identifier "com.getchef.pkg.#{proj_to_work_around_cleanroom.name}"
  #signing_identity "Developer ID Installer: Chef Software, Inc. (EU3VF8YLX2)"
end
compress :dmg

msi_upgrade_code = "3A542C80-3784-4C03-A2CE-94FED4EB7002"
project_location_dir = name
package :msi do
  fast_msi true
  upgrade_code msi_upgrade_code
  wix_candle_extension "WixUtilExtension"
  wix_light_extension "WixUtilExtension"
  #signing_identity "5935fa66aa9f1c3f5b41092adcd75619dd51c918", machine_store: true
  parameters ProjectLocationDir: project_location_dir
end

package :appx do
  #signing_identity "‎5935fa66aa9f1c3f5b41092adcd75619dd51c918", machine_store: true
end
