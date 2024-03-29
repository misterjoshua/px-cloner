# PX Cloner Script for Portworx

This script uses Portworx/Stork 2.2+ ApplicationClone to clone a namespace. It creates an ApplicationClone resource in kube-system with the details of the clone, opting for `replacePolicy: Delete`.

## Example Usage

Bash Script:

```
$ ./cloner.sh src-ns dest-ns
Submitting ApplicationClone request.
applicationclone.stork.libopenstorage.org/clone-src-ns-to-dest-ns-1575506800 created
Application clone stage: Applications
Application clone stage: Final
Restarting pods
pod "tiller-deploy-5cb54b77bc-ntgrc" deleted
pod "wordpress-lamp-7f9cf9cffb-cqtpd" deleted
```

Powershell Script:

```
PS C:\script> .\cloner.ps1 src-ns dest-ns
Submitting ApplicationClone request.
applicationclone.stork.libopenstorage.org/clone-src-ns-to-dest-ns-1575506800 created
Application clone stage: Applications
Application clone stage: Final
Restarting pods
pod "tiller-deploy-5cb54b77bc-ntgrc" deleted
pod "wordpress-lamp-7f9cf9cffb-cqtpd" deleted
```

## Skipping Resources

To skip cloning specific resources from namespace to namespace, annotate the source resource with `stork.libopenstorage.org/skipresource` and Portworx & Stork should skip over it. This may be useful, for instance, if you're cloning an application from one environment to another, but want to leave the ingress resources alone. In this case, you'd annotate the ingress resources in the source namespace with `stork.libopenstorage.org/skipresource`.
