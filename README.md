NAME
====

Crypt::Passphrase - managing passwords in a cryptographically agile manner

SYNOPSIS
========

```raku
 my $authenticator = Crypt::Passphrase.new(
	:encoder<Argon2>,
	:validators<BCrypt Scrypt>
 );

 my $hash = get-hash($user);
 if (!$authenticator.verify-password($password, $hash)) {
     die "Invalid password";
 }
 elsif ($authenticator.needs-rehash($hash)) {
     update-hash($user, $authenticator.hash-password($password));
 }
```

DESCRIPTION
===========

This module manages the passwords in a cryptographically agile manner. Following Postel's principle, it allows you to define a single scheme that will be used for new passwords, but several schemes to check passwords with. It will be able to tell you if you should rehash your password, not only because the scheme is outdated, but also because the desired parameters have changed.

new(%args)
----------

This creates a new `Crypt::Passphrase` object. It takes two named arguments:

  * `encoder`

    A `Crypt::Passphrase` object has a single encoder. This can be passed in three different ways:

        * A simple string

          The name of the encoder class. If the value starts with a `+`, the `+` will be removed and the remainder will be taken as a fully-qualified package name. Otherwise, `Crypt::Passphrase::` will be prepended to he value.

          The class will be loaded, and constructed without arguments.

        * A hash

          The `module` entry will be used to load a new Crypt::Passphrase module as described above, the other arguments will be passed to the constructor. This is the recommended option, as it gives you full control over the password parameters.

        * A Crypt::Passphrase::Encoder object

          This will be used as-is.

    This argument is mandatory.

  * `validators`

    This is a list of additional validators for passwords. These values can each either be the same an encoder value, except that the last entry may also be a coderef that takes the password and the hash as its arguments and returns a boolean value.

    The encoder is always considered as a validator and thus doesn't need to be explicitly specified.

hash-password($password)
------------------------

This will hash a password with the encoder cipher, and return it (in crypt format). This will generally use a salt, and as such will return a different value each time even when called with the same password.

verify-password($password, $hash)
---------------------------------

This will check a password satisfies a certain hash.

needs-rehash($hash)
-------------------

This will check if a hash needs to be rehashed, either because it's in the wrong cipher or because the parameters are insufficient.

Calling this only ever makes sense after a password has been verified.

TIPS AND TRICKS
===============

Custom configurations
---------------------

While encoders generally allow for a default configuration, I would strongly encourage anyone to research what settings work for your application. It is generally a trade-off between usability/resources and security.

Unicode
-------

`Crypt::Passphrase` considers passwords to be text, and as such you should ensure any password input is decoded if it contains any non-ascii characters. `Crypt::Passphrase` will take care of both normalizing and encoding such input.

DOS attacks
-----------

Hashing passwords is by its nature a heavy operations. It can be abused by malignant actors who want to try to DOS your application. It may be wise to do some form of DOS protection such as a proof-of-work schemei or a captcha.

Levels of security
------------------

In some situations, it may be appropriate to have different password settings for different users (e.g. set them more strict for administrators than for ordinary users).

SEE ALSO
========

  * [Crypt::Passphrase::Argon2](Crypt::Passphrase::Argon2)

  * [Crypt::Passphrase::Bcrypt](Crypt::Passphrase::Bcrypt)

AUTHOR
======

Leon Timmermans <fawaka@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2021 Leon Timmermans

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

