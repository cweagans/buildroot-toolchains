# Buildroot Toolchains

This repository builds and packages [buildroot](https://www.buildroot.org) toolchains
that can be imported and used with the [external toolchain](https://buildroot.org/downloads/manual/manual.html#external-toolchain-backend)
functionality.

## Guidelines

* Only the current stable release and the current LTS release are packaged
* Only Linux binaries are provided
* Commonly used architectures are supported
* Changes to Buildroot configuration should be kept to a minimum, and should only be driven by:
    * Hard requirements for exporting a toolchain
    * Security improvements for end-users
    * Performance improvements for end-users

## Security

Because you're (presumably) building your own Linux with these toolchains, it's
important to me that the path from source -> compiled toolchain is fully auditable
without having to download and compile the entire toolchain yourself. To that
end, here are the things that I've done so far that should facilitate that:

* Buildroot packages are only downloaded via HTTPS
* Before downloading, the build checks the currently active certificate on www.buildroot.org against the [Certificate Transparency Log](https://certificate.transparency.dev/) to ensure that the right certificate is in use on www.buildroot.org.
* After downloading, the buildroot tarball is checked against the signature that the Buildroot maintainers have provided.
* When the above checks pass, the download for that specific release is cached as long as possible.

TODO:
* SHA256 hashes are provided for all files attached to releases in this repository
* The SHA256 hashes are also _displayed_ in the Github Actions output so that you can verify that the file that was built by Github Actions is actually the file that is attached to any given release.
* No behind-the-scenes operations are taking place: the entirety of the build process is included in this repository for anyone to audit. The only configured secret in this repository is the auth token used to create releases + upload files.

If you have any other ideas for how to further secure the build process, please
open an issue (or a PR!). The goal here is that people don't have to trust _me_,
but instead can _verify_ that these toolchains are safe to use.
