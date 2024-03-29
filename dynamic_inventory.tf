
resource "local_file" "ansible_inventory" {
  count = length(module.ubuntu.*.public_ip) > 0 || length(module.redhat.*.public_ip) > 0 ? 1 : 0

  depends_on = [aws_launch_template.registration_app, aws_autoscaling_group.this, module.ubuntu, module.redhat, data.aws_instances.this]
  content = templatefile("${path.module}/templates/inventory.tmpl",
    {
      amazon_ec2_cfg = "${data.aws_instances.this.public_ips}",
      ubuntu_ec2_cfg = "${module.ubuntu.*.public_ip}",
      redhat_ec2_cfg = "${module.redhat.*.public_ip}"
    }
  )
  filename = "${path.module}/ansible/inventory/hosts"
}

resource "local_file" "ansible_inventory_private" {
  count = length(module.ubuntu.*.private_ip) > 0 || length(module.redhat.*.private_ip) > 0 ? 1 : 0

  depends_on = [aws_launch_template.registration_app, aws_autoscaling_group.this, module.ubuntu, module.redhat, data.aws_instances.this]
  content = templatefile("${path.module}/templates/private_inventory.tmpl",
    {
      amazon_hostname = "${data.aws_instances.this.private_ips}",
      ubuntu_hostname = "${module.ubuntu.*.tags_all[*].Name}",
      redhat_hostname = "${module.redhat.*.tags_all[*].Name}"
    }
  )
  filename = "${path.module}/ansible/inventory/privatehosts"
}
