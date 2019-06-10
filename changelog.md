# Changelog

# 1.0.4 - TBD

# 1.0.3 - June 10, 2019
- Add Logs for Provision
- Add Provider Support for Parallels ( Pro )
- Fixed Shared Folder Permissions for Parallels

# 1.0.2 - June 5, 2019
- Changed vm.name
- Add Custom Title
- Removed Custom Settings
- Add Provider for Microsoft Hyper-V
- Fixed Shared Folder Permissions for Microsoft Hyper-V
- Change VM name for Microsoft Hyper-V

## 1.0.1 - May 23, 2019
- Disabled `/vagrant` by default
- New Shared Folder `provision`, `srv/provision`
- New Shared Folder `certificates`, `srv/certificates`
- Changed all trigger location from `/vagrant` to `/srv/`
- Add Script inline for `/vagrant`
- Modify `/srv/provision/resources.sh`
- Modify `/srv/provision/utility.sh`
- Moved the symlink to the sandbox-resources for tls-ca
- Updated apache.conf for certificates
- Add contributing.md
- Updated provision/sites.sh to use custom feature
- Add Default Plugins during installation
- Updated `sandbox-setup.yml`

## 1.0.0 - May 1, 2019
- Initial Public Release