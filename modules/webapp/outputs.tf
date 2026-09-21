output "instance_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}
output "assets_bucket_name" {
  description = "Name of the private assets bucket"
  value       = aws_s3_bucket.assets.bucket
}
