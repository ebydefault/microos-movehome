# WARNING

The script is supposed to be part of openSUSE MicroOS combustion script,
to run at provisioning stage.

Don't try to run it as usual shell script,
let alone in an already installed system!

Include it at the very end of combustion script to use.

Beware.
The script has not been throughfully tested.

# Rationale

openSUSE MicroOS appliance (prebuilt VM image) has a separate
`/var` partition that will autogrow every time its disk gets enlarged.
This feature is handy for rootful containers.
Since their storages reside in `/var/lib/container/storage`,
it keeps `/` partition clean and never gets full,
while making sure each container gets as much space as they need.

But I prefer rootless containers,
and let their storages live under my
`$(HOME)/.local/share/containers/storage`,
as podman's default.

This means my containers may run out of space,
since the home directory lies inside '/' partition,
right before '/var',
without any feasible solution
but to attach more storage
and move my home around--not as simple as enlarging a single disk
and letting it autogrow,
as with rootful containers.

Then I got inspired by how Fedora CoreOS
symlinks its `/home` to `/var/home`.
I followed suit,
with combustion and some SELinux adjustments.
It was ugly.
But it just worked.
My rootless containers ran flawlessly without worry on MicroOS.

Even so, I still get nervous whenever I must mangle with SELinux.

But thank God it's BTRFS!

`/home` is a mere subvolume mounted at `/`.
And I can take snapshot from any subvolume
to send it over partitions at *block level*,
meaning with all SELinux contexts attached.

So I move my home under `/var/@/home` subvolume,
taking advantage of /var partition autogrow feature,
mount it as ordinary /home
without modifying `/etc/fstab` entry but its UUID.

It's not beautiful indeed,
but much elegant than my previous solution.
