# gcloud_hosts

Update your hosts file based on gcloud compute instances.

This is handy when used in conjunction with something like [sshuttle](https://github.com/sshuttle/sshuttle),
allowing you to have a "poor man's vpn".

## Installation

```shell
$ gem install gcloud_hosts
```

## Requirements

Requires [gcloud tool](https://cloud.google.com/sdk/gcloud/) installed and authenticated against at least 1 GCP project.

## Usage

```shell
$ gcloud_hosts -h
Usage: $ gcloud_hosts [options]
    -g, --gcloud GCLOUD              Path to gcloud executable. Defaults to PATH location
    -p, --project PROJECT            gcloud project to use. Defaults to default gcloud configuration.
    -n, --network NETWORK            gcloud network to filter on. Defaults nil.
    -d, --domain DOMAIN              Domain to append to all hosts. Default: "c.[PROJECT].internal"
        --public PUBLIC              Pattern to match for public/bastion hosts. Use public IP for these. Defaults to nil
        --[no-]exclude-public        Exclude public hosts from list when updating hosts file. Allows them to be managed manually. Defaults to false
    -f, --file FILE                  Hosts file to update. Defaults to /etc/hosts
    -b, --backup BACKUP              Path to backup original hosts file to. Defaults to FILE with '.bak' extension appended.
        --[no-]dry-run               Dry run, do not modify hosts file. Defaults to false
        --[no-]delete                Delete the project from hosts file. Defaults to false
        --help                       Show this message
        --version                    Show version
```

## Example

Update your hosts file using gcloud_hosts:

```shell
$ sudo gcloud_hosts -p my-cool-project --public bastion

```
Start sshuttle session:

```shell
$ sshuttle --remote=bastion01 --daemon --pidfile=/tmp/sshuttle.pid 192.168.1.0/24
```

Now your hosts file will contain entries for all compute instances in the project,
and you can ssh directly to them from your local machine.

Hosts matching the pattern passed in with the `--public` flag will have their public
IP address added to your host file instead of the their private internal IP address.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/atongen/gcloud_hosts](https://github.com/atongen/gcloud_hosts).
