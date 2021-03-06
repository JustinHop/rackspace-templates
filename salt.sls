parameter_groups:
    -
        parameters:
            - image
            - master_flavor
        label: 'Salt Master Settings'
    -
        parameters:
            - minion_flavor
            - number_of_minions
        label: 'Salt Minion Settings'
    -
        parameters:
            - salt_network_range
        label: rax-dev-params
heat_template_version: '2013-05-23'
description: "This is a Heat template to deploy a salt master and a number of minions.\n"
parameters:
    master_flavor:
        default: '2 GB General Purpose v1'
        label: 'Server Size'
        type: string
        description: "Rackspace Cloud Server flavor to use. The size is based on the amount of\nRAM for the provisioned server.\n"
        constraints:
            -
                description: "Must be a valid Rackspace Cloud Server flavor for the region you have\nselected to deploy into.\n"
                allowed_values:
                    - '1 GB General Purpose v1'
                    - '2 GB General Purpose v1'
                    - '4 GB General Purpose v1'
                    - '8 GB General Purpose v1'
                    - '15 GB I/O v1'
                    - '30 GB I/O v1'
                    - '1GB Standard Instance'
                    - '2GB Standard Instance'
                    - '4GB Standard Instance'
                    - '8GB Standard Instance'
                    - '15GB Standard Instance'
                    - '30GB Standard Instance'
    minion_flavor:
        default: '1 GB General Purpose v1'
        label: 'Server Size'
        type: string
        description: "Rackspace Cloud Server flavor to use. The size is based on the amount of\nRAM for the provisioned server.\n"
        constraints:
            -
                description: "Must be a valid Rackspace Cloud Server flavor for the region you have\nselected to deploy into.\n"
                allowed_values:
                    - '1 GB General Purpose v1'
                    - '2 GB General Purpose v1'
                    - '4 GB General Purpose v1'
                    - '8 GB General Purpose v1'
                    - '15 GB I/O v1'
                    - '30 GB I/O v1'
                    - '1GB Standard Instance'
                    - '2GB Standard Instance'
                    - '4GB Standard Instance'
                    - '8GB Standard Instance'
                    - '15GB Standard Instance'
                    - '30GB Standard Instance'
    image:
        default: 'Ubuntu 14.04 LTS (Trusty Tahr)'
        label: 'Operating System'
        type: string
        description: "Server image used for all servers that are created as a part of this\ndeployment.\n"
        constraints:
            -
                description: 'Must be a supported operating system.'
                allowed_values:
                    - 'Ubuntu 12.04 LTS (Precise Pangolin) (PVHVM)'
                    - 'Ubuntu 14.04 LTS (Trusty Tahr)'
    salt_network_range:
        default: 192.168.224.0/20
        type: string
        description: 'Private Network to use for Salt Communication'
        label: 'Private Network CIDR'
    number_of_minions:
        default: 2
        label: 'Number of Minions'
        type: number
        description: 'Number of minion servers to deploy.'
        constraints:
            -
                range:
                    max: 100
                    min: 0
                description: 'Must be between 0 and 100 servers'
outputs:
    salt_master_ip:
        description: 'Salt Master IP'
        value:
            get_attr:
                - salt_master_server
                - accessIPv4
    private_key:
        description: 'SSH Private Key'
        value:
            get_attr:
                - ssh_key
                - private_key
    minion_public_ips:
        description: 'Minion IPs'
        value:
            get_attr:
                - salt_minion_servers
                - accessIPv4
resources:
    salt_master_server:
        type: 'Rackspace::Cloud::Server'
        properties:
            flavor:
                get_param: master_flavor
            name: salt-master
            key_name:
                get_resource: ssh_key
            image:
                get_param: image
            user_data: "#!/bin/bash\napt-get update\napt-get install python-software-properties -y\nadd-apt-repository ppa:saltstack/salt -y\napt-get update\napt-get install salt-master salt-cloud -y\nufw allow salt\n"
            networks:
                -
                    uuid: 00000000-0000-0000-0000-000000000000
                -
                    uuid: 11111111-1111-1111-1111-111111111111
                -
                    uuid:
                        get_resource: salt_network
    salt_network:
        type: 'Rackspace::Cloud::Network'
        properties:
            cidr:
                get_param: salt_network_range
            label: salt_network
    ssh_key:
        type: 'OS::Nova::KeyPair'
        properties:
            name:
                get_param: 'OS::stack_id'
            save_private_key: true
    salt_minion_servers:
        depends_on: salt_master_server
        type: 'OS::Heat::ResourceGroup'
        properties:
            count:
                get_param: number_of_minions
            resource_def:
                type: 'Rackspace::Cloud::Server'
                properties:
                    flavor:
                        get_param: minion_flavor
                    name: salt-minion%index%
                    key_name:
                        get_resource: ssh_key
                    image:
                        get_param: image
                    user_data:
                        str_replace:
                            params:
                                '%salt_master%':
                                    get_attr:
                                        - salt_master_server
                                        - networks
                                        - salt_network
                                        - 0
                            template: "#!/bin/bash\napt-get update\napt-get install python-software-properties -y\nadd-apt-repository ppa:saltstack/salt -y\napt-get update\napt-get install salt-minion -y\nsed -i 's/^#master: salt$/master: %salt_master%/' /etc/salt/minion\n/etc/init.d/salt-minion restart\n"
                    networks:
                        -
                            uuid: 00000000-0000-0000-0000-000000000000
                        -
                            uuid: 11111111-1111-1111-1111-111111111111
                        -
                            uuid:
                                get_resource: salt_network



