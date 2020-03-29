import yaml
import sys

prefix = sys.argv[1]
interface_name = sys.argv[2]
interface_type = sys.argv[3]
network = sys.argv[4]
mask = sys.argv[5]

config = {}
with open(r'/etc/netplan/99-juju.yaml') as file:
    # The FullLoader parameter handles the conversion from YAML
    # scalar values to Python the dictionary format
  config = yaml.load(file)
    if interface_type == "simple":
        if interface_name == "ens8":
            if not 'bridges' in config['network']:
                config['network']['bridges'] = {}
            config['network']['bridges']['prvtbr'] = {'addresses': [network + str(prefix) + '/' + mask],
                                                      'dhcp4': false,
                                                      'parameters': {'forward-delay': 0, 'priority': 0, 'stp': false},
                                                      'interfaces': [interface_name]
                                                    }
with open(r'/etc/netplan/99-juju.yaml', 'w') as file:
    documents = yaml.dump(config, file)
