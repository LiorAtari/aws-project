resource "aws_elb" "lioratari-elb" {
  name = "lioratari-elb"
  availability_zones = ["eu-north-1a"]
  listener {
    instance_port = 30000
    instance_protocol = "HTTP"
    lb_port = 80
    lb_protocol = "HTTP"
  }
}