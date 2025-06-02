#!/usr/bin/env python3
import json
import re
import subprocess

# Read terraform output -json from stdin
output = subprocess.check_output(["terraform", "output", "-json"], stderr=subprocess.DEVNULL)
#output = sys.stdin.read()
data = json.loads(output)

inventory = []

# Build inventory dynamically based on Terraform output
for key, val in data.items():
    match = re.match(r"(?P<group>.+)_instance_private_ips$", key)
    if match:
        group_name = match.group("group")
        ip_map = val["value"]  # map of instance_name -> private_ip
        inventory.append(f"[{group_name}]")
        for instance_name, private_ip in ip_map.items():
            inventory.append(f"{instance_name} ansible_host={private_ip}")
        inventory.append("")  # newline between groups

# Add global vars block
inventory.append("[all:vars]")
inventory.append("ansible_user=ubuntu")
inventory.append("ansible_ssh_private_key_file=./../Terraform/terra-full.pem")
inventory.append("ansible_python_interpreter=/usr/bin/python3")

# Output inventory
print("\n".join(inventory))


#    python3 Generate_inventories.py > ./../Ansible/inventories/dev