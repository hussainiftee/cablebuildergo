# -----
# --- Compute Output.
# -----

#---- ELB 
output "alb_dns_name" {
  value = aws_lb.cbg_elb.dns_name
}

# ----- End.  