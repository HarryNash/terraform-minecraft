variable "region" {
  type        = string
  description = "Where you want your server to be. The options are here https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html."
  //default = "ap-southeast-2"
  default = "us-east-1"
}

variable bucket_arn {
    default = "arn:aws:s3:::086133709882-minecraft-server-1/*"
}