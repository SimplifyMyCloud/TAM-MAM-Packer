# build.sh
#!/bin/bash
set -e

# Build backend AMI
cd packer
packer init tams-mams-backend.pkr.hcl
packer build tams-mams-backend.pkr.hcl

# Build frontend AMI
packer init tams-mams-frontend.pkr.hcl
packer build tams-mams-frontend.pkr.hcl