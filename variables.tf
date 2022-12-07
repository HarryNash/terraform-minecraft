variable "region" {
  type        = string
  description = "Where you want your server to be. The options are here https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html."
  default = "ap-southeast-2"
}

variable bucket_arn {
    default = "arn:aws:s3:::086133709882-minecraft-server-1/*"
}

/*
variable "bucket_name" {    
    default = "086133709882-minecraft-server-1"
}

variable "acl_value" {
    default = "private"
}

variable "your_ip" {
  type        = string
  description = "Only this IP will be able to administer the server. Find it here https://www.whatsmyip.org/."
}

variable "your_private_key" {
  type        = string
  description = "This will be in ~/.ssh/id_rsa.pub by default."
  default = "C:\Users\dylan\.ssh\kp-ec2-minecraft.pem"
}

variable "mojang_server_url" {
  type        = string
  description = "Copy the server download link from here https://www.minecraft.net/en-us/download/server/."
}
*/