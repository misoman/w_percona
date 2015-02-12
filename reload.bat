@ECHO OFF
rm -rf %userprofile%/.berkshelf
rm .vagrant/machines/webapp/virtualbox/synced_folders
vagrant reload --provision