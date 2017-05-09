#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Copyright © 2016 Samsung CNCT
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

DOCUMENTATION = '''  
---
module: jsonschema
short_description: Validates a JSON document against a JSON schema
'''

EXAMPLES = '''
- name: Load configuration file
  include_vars:
    file: "{{ config_filename }}"
    name: config

- name: Validate configuration against JSON schema
  jsonschema:
    config: config
    schema_filename: "{{ schema_filename }}"
  register: validation

- name: Fail invalid configurations
  fail:
    msg: >-
         {{ config_filename }} was invalid. Exception raised was
         {{ validation.result.exception }}
    when: validation.result.is_valid
 
'''

import re

from ansible.module_utils.basic import *
from ansible import errors

try:
    import yaml
    import jsonschema
    import netaddr
except ImportError as e:
    raise errors.AnsibleModuleError(e)

_semver_regex = (r'^v?(0|[1-9]\d*)\.'
                 r'(0|[1-9]\d*)\.'
                 r'(0|[1-9]\d*)'
                 r'(-(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*)?'
                 r'(\+[0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*)?$')

@jsonschema.FormatChecker.cls_checks('symver')
def validate_semver_format(entry):
    m = re.match(_semver_regex, entry)
    return m is not None    

@jsonschema.FormatChecker.cls_checks('cidr')
def _validate_cidr_format(cidr):
    try:
        netaddr.IPNetwork(cidr)
    except netaddr.AddrFormatError:
        return False
    if '/' not in cidr:
        return False
    if re.search('\s', cidr):
        return False
    return True

class ApiValidator(jsonschema.Draft4Validator):
    def __init__(self, schema):
        format_checker = jsonschema.FormatChecker()
        super(ApiValidator, self).__init__(schema,
                                           format_checker=format_checker)

def validate_document(config, schema):
    '''Attempts to validate config against schema. Returns a dictionary containing
    the config and schema, a boolean is_valid indicating whether the config is
    valid under the schema, and exception of type ValidationError (SchemaError) if
    config (schema) is invalid respectively.
    '''
    result={ 'config': config,
             'schema': schema,
             'is_valid': True,
    }
    try:
        validator = ApiValidator(schema)
        validator.validate(config)
    except (jsonschema.ValidationError, jsonschema.SchemaError) as e:
        result['is_valid'] = False
        result['exception'] = e
    return result

def load_documents(config=None, config_filename=None,
                   schema=None, schema_filename=None):
    '''Accepts a config and schema as either python objects, or files containing
    YAML or JSON, and returns python objects.
    '''
    if config_filename:
        with open(config_filename, 'r') as config_file:
            config = yaml.load(config_file)

    if schema_filename:
        with open(schema_filename, 'r') as schema_file:
            schema = yaml.load(schema_file)

    return config, schema

def main():
    module = AnsibleModule(
        argument_spec={
            'config': { 'required': False, 'type': 'dict' },
            'config_filename': { 'required': False, 'type': 'str' },
            'schema': { 'required': False, 'type': 'dict' },
            'schema_filename': { 'required': False, 'type': 'str' },
        },
        mutually_exclusive=[
            [ 'config', 'config_filename' ],
            [ 'schema', 'schema_filename' ],
        ],
        required_one_of=[
            [ 'config', 'config_filename' ],
            [ 'schema', 'schema_filename' ],
        ],
        supports_check_mode=True
    )

    config, schema = load_documents(**module.params)
    result = validate_document(config, schema)
    if 'exception' in result:
        module.fail_json(changed=False, msg="Validation failed", result=result)
    module.exit_json(changed=False, msg="Validation succeeded", result=result)

if __name__ == '__main__':  
    main()
