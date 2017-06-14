import semver

def max_semver(data):
    v = max([semver.parse(x[1:]) for x in data])
    string = semver.format_version(v['major'],v['minor'],v['patch'],v['prerelease'],v['build'])
    return 'v' + string

class FilterModule(object):
  ''' Select the highest "v"-prefixed version string '''
  def filters(self):
    return {
      'max_semver' : max_semver
    }
 
