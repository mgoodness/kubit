## Upgrading from v1.5.2-alpha

1. Update VPC - **causes brief worker unavailability**
  ```
  terraform apply --target=module.vpc
  ```

2. Create new worker security groups - **must be manually added to existing workers after creation**
  ```
  terraform apply \
    --target=module.security_groups.aws_security_group.workers_static \
    --target=module.security_groups.aws_security_group.workers_dynamic
  ```

3. Update controllers - **must be rotated after update**
  ```
  terraform apply --target=module.controllers
  ```

4. Update worker pools - **must be rotated after update**
  ```
  terraform apply \
    --target=module.workers_t2_large_0 \
    --target=module.workers_t2_large_1 \
    --target=module.workers_t2_large_2
  ```

5. Delete old worker security group - **may cause brief unavailability of Kubernetes LoadBalancer Services**
  ```
  terraform apply --target=module.security_groups
  ```

6. [Upgrade etcd nodes to v3](https://github.com/coreos/etcd/blob/master/Documentation/upgrades/upgrade_3_0.md)
  - kubit-etcd-01 & kubit-etcd-02
    ```
    sudo systemctl stop etcd2 && \
    sudo mkdir -p /var/lib/etcd && \
    sudo cp -r /var/lib/etcd2/* /var/lib/etcd && \
    sudo chown -R etcd /var/lib/etcd

    sudo mkdir -p /etc/systemd/system/etcd-member.service.d && \
    sudo tee /etc/systemd/system/etcd-member.service.d/99-upgrade.conf > /dev/null <<EOF
    [Service]
    Environment="ETCD_CERT_FILE=/etc/etcd2/ssl/etcd.pem"
    Environment="ETCD_CLIENT_CERT_AUTH=true"
    Environment="ETCD_KEY_FILE=/etc/etcd2/ssl/etcd-key.pem"
    Environment="ETCD_LISTEN_CLIENT_URLS=https://0.0.0.0:2379"
    Environment="ETCD_LISTEN_PEER_URLS=https://0.0.0.0:2380"
    Environment="ETCD_PEER_CERT_FILE=/etc/etcd2/ssl/etcd.pem"
    Environment="ETCD_PEER_CLIENT_CERT_AUTH=true"
    Environment="ETCD_PEER_KEY_FILE=/etc/etcd2/ssl/etcd-key.pem"
    Environment="ETCD_PEER_TRUSTED_CA_FILE=/etc/etcd2/ssl/ca.pem"
    Environment="ETCD_SSL_DIR=/etc/etcd2/ssl"
    Environment="ETCD_TRUSTED_CA_FILE=/etc/etcd2/ssl/ca.pem"
    EOF

    grep ETCD_ADVERTISE_CLIENT_URLS /var/run/systemd/system/etcd2.service.d/20-cloudinit.conf | \
        sudo tee -a /etc/systemd/system/etcd-member.service.d/99-upgrade.conf
    grep ETCD_INITIAL_ADVERTISE_PEER_URLS /var/run/systemd/system/etcd2.service.d/20-cloudinit.conf | \
        sudo tee -a /etc/systemd/system/etcd-member.service.d/99-upgrade.conf
    grep ETCD_NAME /var/run/systemd/system/etcd2.service.d/20-cloudinit.conf | \
        sudo tee -a /etc/systemd/system/etcd-member.service.d/99-upgrade.conf

    sudo systemctl daemon-reload && \
    sudo systemctl start etcd-member

    etcdctl cluster-health
    ```

7. [Migrate etcd data to encrypted EBS](https://coreos.com/etcd/docs/latest/etcd-live-cluster-reconfiguration.html)
  - kubit-etcd-03
    ```
    (on kubit-etcd-01 or kubit-etcd-02)
    etcdctl cluster-health
    etcdctl member remove <kubit-etcd-03-id>
    etcdctl member add kubit-etcd-03 https://kubit-etcd-03.kubit.local:2380

    terraform apply --target=module.etcd_node_03

    (on new kubit-etcd-03)
    sudo tee /etc/systemd/system/etcd-member.service.d/99-restore.conf > /dev/null <<EOF
    [Service]
    Environment="ETCD_DISCOVERY_SRV="
    Environment="ETCD_INITIAL_CLUSTER=kubit-etcd-02=https://kubit-etcd-02.kubit.local:2380,kubit-etcd-03=https://kubit-etcd-03.kubit.local:2380,kubit-etcd-01=https://kubit-etcd-01.kubit.local:2380"
    Environment="ETCD_INITIAL_CLUSTER_STATE=existing"
    EOF

    grep ETCD_NAME /etc/systemd/system/etcd-member.service.d/30-environment.conf | \
        sudo tee -a /etc/systemd/system/etcd-member.service.d/99-restore.conf

    sudo systemctl stop etcd-member && \
    sudo rm -rf /var/lib/etcd/* && \
    sudo systemctl daemon-reload && \
    sudo systemctl start etcd-member

    etcdctl cluster-health
    ```
  - repeat for kubit-etcd-01 & kubit-etcd-02
