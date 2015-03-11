# Cookbook Name:: varnish
# Resource:: vmod
# Author:: Matthew Thode <matt.thode@rackspace.com>
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

actions 'add', 'remove'
default_action 'add'

attribute :name, kind_of: String, name_attribute: true
attribute :source, kind_of: String, required: true
attribute :branch, kind_of: String, required: false
attribute :packages, kind_of: Array, default: []