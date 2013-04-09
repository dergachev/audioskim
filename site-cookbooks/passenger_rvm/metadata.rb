name              "passenger_rvm"
maintainer        "Alex Dergachev"
maintainer_email  "alex@evolvingweb.ca"
license           "Apache 2.0"
description       "Ensures compatibility between nginx::passenger and rvm"
long_description  "Please refer to README.md (it's long)."
version           "0.9.1"

# provides chef_gem resource to chef <= 0.10.8 and fixes for chef < 10.12.0
depends "nginx"
depends "rvm"
depends "runit"
depends "bluepill"

supports "ubuntu" # Only tested on precise. In particular, passenger_rvm::bluepill is likely insufficient on redhat
