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
        if interface_name == "ethmon":
            config['network']['ethernets']['ethmon'] = {'addresses': [network + str(prefix) + '/' + mask],}
        if interface_name == "ethexport":
            config['network']['ethernets']['ethexport'] = {'addresses': [network + str(prefix) + '/' + mask],}
with open(r'/etc/netplan/99-juju.yaml', 'w') as file:
    documents = yaml.dump(config, file)
