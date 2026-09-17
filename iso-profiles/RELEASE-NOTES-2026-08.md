2026-08 RELEASE NOTES
---------------------

The second official release for 2026 comes with kernel 7.1.8 and the latest versions of software at the time of release. As usual, we provide a wide range of installation desktops and init systems, suited to all levels of Linux experience, but we have reduced their combinations; this will allow faster testing and release cycles.

- The default X server is again Xorg; XLibre is still packaged and available for installation.
- User services have been fully implemented for OpenRC and dinit. They can also be enabled for runit and s6 via userspawn, however, for the time being, this task is left on the end user.
- Full Wayland support only in Plasma. Our other DEs are in various stages of Wayland support, but not yet ready for daily use.
