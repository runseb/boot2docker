Boot2docker variant to run Kubernetes solo
===========================================

This is a fork of the new boot2docker with a Kubernetes variant.

Currently the original [boot2docker](https://github.com/boot2docker/boot2docker) is still being used in `docker-machine`, this repository represents the new boot2docker which might be used at some point. It is modified to build a boot2docker variant that we call *boot2k8s*. This variant installs Kubernetes in this single ISO for testing and development on local machines.

This repository is different from [boot2k8s](https://github.com/skippbox/boot2k8s) which is a variant of the current boot2docker.

A bit confusing, I know.

Preview Notice
--------------

This repository is **a technical preview only** at this point.  If you are looking for boot2docker, you can find it at [github.com/boot2docker/boot2docker](https://github.com/boot2docker/boot2docker). If you are looking for a `docker-machine` compatible boot2k8s, you can find it at [github.com/skippbox/boot2k8s](https://github.com/skippbox/boot2k8s)

This is intended to be used with [Docker Machine](https://docs.docker.com/machine/), but should be mostly usable outside that context as well.  Be warned that the largest unformatted disk found during boot _will_ be partitioned and formatted for use unless a partition with the label `data` is found (which will be used automatically instead).

Build
-----

Run `make` to build the ISO and `make run` to start the VM with VirtualBox:

    $ make boot2docker-k8s.iso
    $ make run

Then `make run` is a convenience build to create the VM, you could do it manually through the UI, or using the `VBoxManage` commands:

    $ VBoxManage createvm --name boot2k8s --ostype "Linux_64" --register
    $ VBoxManage storagectl boot2k8s --name "IDE Controller" --add ide
    $ VBoxManage storageattach boot2k8s --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium ./boot2docker-k8s.iso
    $ VBoxManage modifyvm boot2k8s --memory 1024
    $ VBoxManage startvm boot2k8s --type headless
    $ VBoxManage controlvm boot2k8s natpf1 k8s,tcp,,8080,,8080

Support
-------

If you experience problems with this `boot2docker` variant called `boot2k8s` or want to suggest improvements please file an [issue](https://github.com/skippbox/boot2docker/issues).
