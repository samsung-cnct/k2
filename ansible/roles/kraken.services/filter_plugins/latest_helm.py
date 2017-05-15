from distutils.version import StrictVersion

def latest_helm(data):
    # Find out all the versions
    file_info = data['files']
    versions = []
    for item in file_info:
        path = item['path']
        version_number = path.split('/')[4][1:]
        versions.append(version_number)
    #Compare versions
    max_version = versions[0]

    for version in versions:
        if StrictVersion(max_version) < StrictVersion(version):
            max_version = version

    return max_version

class FilterModule(object):
    ''' Unicorn filter that seems to be just a name for now so fuzzy shiny unicorns ahoy '''
    def filters(self):
        return {
            'latest_helm': latest_helm
        }
