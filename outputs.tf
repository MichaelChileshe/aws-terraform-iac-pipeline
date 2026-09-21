output "web_url" {
  description = "URL of the deployed web server"
  value       = "http://${module.webapp.instance_public_ip}"
}

output "instance_public_ip" {
  description = "Public IP of the web server"
  value       = module.webapp.instance_public_ip
}

output "assets_bucket" {
  description = "Name of the private assets bucket"
  value       = module.webapp.assets_bucket_name
}
