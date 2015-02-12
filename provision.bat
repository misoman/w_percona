@ECHO OFF
rm -rf %userprofile%/.berkshelf
rm .vagrant/machines/webapp/virtualbox/synced_folders
REM vagrant reload --provision
vagrant provision