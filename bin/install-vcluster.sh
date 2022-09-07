#!/bin/sh

curl -s -L "https://github.com/loft-sh/vcluster/releases/latest" | sed -nE 's!.*"([^"]*vcluster-linux-amd64)".*!https://github.com\1!p' | xargs -n 1 curl -L -o vcluster && chmod +x vcluster

sudo mv vcluster /usr/local/bin

# Memory and CPU limits
# We can pack about 100 vclusters into 8CPU 32GB RAM 
# with this configuration.
cat > ./vcluster.yaml << EOF

-- 
vcluster:
  resources:
    limits:
      memory: 290Mi
      cpu: 70m
    requests:
      cpu: 10m
      memory: 128Mi

EOF
