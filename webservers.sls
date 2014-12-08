heat_template_version: 2013-05-23

description: Configuration for Web Servers

parameters:

  salt_master:
    description: the salt master to config from
    type: string
    default: master01.salt.dev1.crowdrise.io

  web1_name:
    description: the instance name
    type: string
    default: http1.www.dev1.crowdrise.io

  web2_name:
    description: the instance name
    type: string
    default: http2.www.dev1.crowdrise.io

  key_name:
    description: Nova keypair name
    type: string
    default: hop-2014-2048
 
resources:
  web1:
    type: "Rackspace::Cloud::Server"
    properties:
      flavor: 2 GB General Purpose v1
      image: Ubuntu 14.04 LTS (Trusty Tahr)
      name: { get_param: web1_name }
      key_name: { get_param: key_name }
      user_data:
        str_replace:
          template: |
            #!/bin/bash -v
            curl -L https://bootstrap.saltstack.com | sudo sh -s -- -A ext.salt.crowdrise.io -U -i %web1_name%
            sudo salt-call state.highstate || true
            sudo salt-call state.highstate
            true
          params:
            "%web1_name%": { get_param: web1_name }
  web2:
    type: "Rackspace::Cloud::Server"
    properties:
      flavor: 2 GB General Purpose v1
      image: Ubuntu 14.04 LTS (Trusty Tahr)
      name: { get_param: web2_name }
      key_name: { get_param: key_name }
      user_data:
        str_replace:
          template: |
            #!/bin/bash -v
            curl -L https://bootstrap.saltstack.com | sudo sh -s -- -A ext.salt.crowdrise.io -U -i %web2_name%
            sudo salt-call state.highstate || true
            sudo salt-call state.highstate
            true
          params:
            "%web2_name%": { get_param: web2_name }

outputs:
  public_ip_web1:
    description: public IP address of web1
    value: { get_attr: [web1, accessIPv4] }
  private_ip_web1:
    description: public IP address of web1
    value: { get_attr: [web1, privateIPv4] }
  public_ip_web2:
    description: public IP address of web2
    value: { get_attr: [web2, accessIPv4] }
  private_ip_web2:
    description: public IP address of web2
    value: { get_attr: [web2, privateIPv4] }
