# RapidKernel
The RapidKernel project aims to provide a painless method for [re-]building a RapidLinux compliant kernel.

## Prerequisites
You will need to be in a booted RapidLinux environment with dev tools available.

## Usage
Clone this project and create a directory to save your modules \
Typically root permissions is required to write to /usr/src \
In this example we will build a 5.10.144 kernel \
by walking through each script in order. \
In Step 1, you will need an old config to import.


```
# Create a directory for storage
mkdir -p /tmp/5.10.144

# Lets build a kernel
cd scripts
sudo ./01-prepare.sh 5.10.144 /opt/RL/packages/rapidkernels/64/5.4.214/config
sudo ./02-build.sh /tmp/5.10.144/

# Find all your new files
ls -l /tmp/5.10.144/
```

## Extra Information
This project requires the Linux Kernel and the AUFS patchset. \
More information about those projects can be found here:
* https://www.kernel.org/
* http://aufs.sourceforge.net/
* https://github.com/sfjro/
