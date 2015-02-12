#!/bin/bash
rm -rf ~/.berkshelf
rm -rf .vagrant/machines/webapp/virtualbox/synced_folders
vagrant reload --provision
