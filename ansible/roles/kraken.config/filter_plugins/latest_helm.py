# from ansible.errors import AnsibleError
# from ansible.plugins.lookup import LookupBase
# from ansible.parsing.yaml.objects import AnsibleUnicode
# from ansible.utils.listify import listify_lookup_plugin_terms
# from jinja2.runtime import StrictUndefined

def latest_helm(data):
    if data == "v1.6":
        return "v1.5"
    return data

class FilterModule(object):
    ''' Unicorn filter that seems to be just a name for now so fuzzy shiny unicorns ahoy '''
    def filters(self):
        return {
            'latest_helm': latest_helm
        }
