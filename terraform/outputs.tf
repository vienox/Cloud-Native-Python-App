output "instance_public_ip" {
  description = "Public IP address of K3s instance"
  value       = aws_eip.k3s.public_ip
}

output "instance_id" {
  description = "ID of EC2 instance"
  value       = aws_instance.k3s.id
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_eip.k3s.public_ip}"
}

output "k3s_api_endpoint" {
  description = "K3s API endpoint"
  value       = "https://${aws_eip.k3s.public_ip}:6443"
}

output "app_url" {
  description = "Application URL"
  value       = "http://${aws_eip.k3s.public_ip}:30080"
}
