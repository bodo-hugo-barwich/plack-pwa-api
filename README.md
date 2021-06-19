# NAME

Plack Twiggy Product REST API

# DESCRIPTION

This service provides the `Product Data` as _REST API_ for the _Plack Twiggy PWA_ Project.

To learn more about the _Plack Twiggy PWA_ Project please visit:
[Plack Twiggy PWA](https://github.com/bodo-hugo-barwich/plack-pwa-web)

The running Version is hosted on _Glitch_ at:
[Plack Twiggy Product REST API](https://plack-pwa-api.glitch.me/)

# REQUIREMENTS

To rebuild this web site the **Minimum Requirements** are to have _Perl_ and `cpanminus` installed.
The site uses the libraries `Plack`, `Twiggy` and `JSON`.
The `Twiggy` Web Server requires the `AnyEvent` library.
The Server Responses are provided completely as `JSON` documents.
The **API Data Structures** are implemented with the `Moose` library for **OO-Design**.

# INSTALLATION

- cpanminus

    The `cpanm` Script will install the dependencies on local user level as they are found in the `cpanfile`.
    To run the installation call the `cpanm` Command within the project directory:

            cpanm -vn --installdeps .
