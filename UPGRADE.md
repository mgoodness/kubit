## Upgrading from v1.5.3

No significant changes required. However, a new set of node labels has been added.

Controllers are now labeled
```
kubernetes.io/role: master
node-role.kubernetes.io/master: true
```

Workers are now labeled
```
kubernetes.io/role: node
node-role.kubernetes.io/node: true
```

The old `kubernetes.io/role` labels will likely be deprecated in a future release. Any node selectors should be updated to use the new `node-role.kubernetes.io` labels.
