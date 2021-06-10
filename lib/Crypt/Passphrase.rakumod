unit class Crypt::Passphrase:ver<0.0.1>:auth<cpan:LEONT>;

use Crypt::Passphrase::Validator;
use Crypt::Passphrase::Encoder;
use Crypt::Passphrase::Fallback;

has Crypt::Passphrase::Encoder:D $!encoder is required;
has Crypt::Passphrase::Validator @!validators;

my multi load-extension(Validator:U $module) {
	require $module;
	return $module;
}
my multi load-extension(Str:D $module) {
	require ::($module);
	die "Could not load $module" if ::($module) eqv Any;
	return ::($module);
}

my proto load-encoder(| --> Crypt::Passphrase::Encoder:D) { * }
my multi load-encoder(Crypt::Passphrase::Encoder:D $encoder) {
	return $encoder;
}
my multi load-encoder(Crypt::Passphrase::Encoder:U $encoder) {
	return $encoder.new;
}
my multi load-encoder(Str:D $encoder is copy) {
	$encoder ~~ s/ ^ <!before '+'>/Crypt::Passphrase::/;
	return load-extension($encoder).new;
}
my multi load-encoder(%configuration is copy) {
	my $class = %configuration<module>:delete;
	return load-extension($class).new(|%configuration);
}

my multi load-validator(Crypt::Passphrase::Encoder:D $validator) {
	return $validator;
}
my multi load-validator(Crypt::Passphrase::Encoder:U $validator) {
	return $validator.new;
}
my multi load-validator(Str:D $validator) {
	return load-extension($validator).new;
}
my multi load-validator(Callable:D $callback) {
	return Crypt::Passphrase::Fallback.new(:$callback);
}
my multi load-validator(%configuration is copy) {
	my $class = %configuration<module>:delete;
	return load-extension($class).new(|%configuration);
}

submethod BUILD(:$encoder, :@validators) {
	my $e = load-encoder($encoder);
	dd $e;
	$!encoder = $e;
	@!validators = [ $!encoder, |@validators.map(&load-validator) ];
}

method hash-password(Str $password --> Str) {
	return $!encoder.hash-password($password.NFC);
}

method needs-rehash(Str $hash --> Bool) {
	return True if $hash !~~ / ^ '$' (\w+) '$' /;
	return $!encoder.needs-rehash($hash);
}

method verify-password(Str $password, Str $hash --> Bool) {
	for @!validators -> $validator {
		if $validator.accepts-hash($hash) {
			return $validator.verify-password($password.NFC, $hash);
		}
	}

	return False
}

=begin pod

=head1 NAME

Crypt::Passphrase - managing passwords in a cryptographically agile manner

=head1 SYNOPSIS

=begin code :lang<raku>

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

=end code

=head1 DESCRIPTION

This module manages the passwords in a cryptographically agile manner. Following Postel's principle, it allows you to define a single scheme that will be used for new passwords, but several schemes to check passwords with. It will be able to tell you if you should rehash your password, not only because the scheme is outdated, but also because the desired parameters have changed.

=head2 new(%args)

This creates a new C<Crypt::Passphrase> object. It takes two named arguments:

=begin item1
C<encoder>

A C<Crypt::Passphrase> object has a single encoder. This can be passed in three different ways:

=begin item2
A simple string

The name of the encoder class. If the value starts with a C<+>, the C<+> will be removed and the remainder will be taken as a fully-qualified package name. Otherwise, C<Crypt::Passphrase::> will be prepended to he value.

The class will be loaded, and constructed without arguments.
=end item2

=begin item2
A hash

The C<module> entry will be used to load a new Crypt::Passphrase module as described above, the other arguments will be passed to the constructor. This is the recommended option, as it gives you full control over the password parameters.
=end item2


=begin item2
A Crypt::Passphrase::Encoder object

This will be used as-is.
=end item2

This argument is mandatory.
=end item1

=begin item1
C<validators>

This is a list of additional validators for passwords. These values can each either be the same an encoder value, except that the last entry may also be a coderef that takes the password and the hash as its arguments and returns a boolean value.

The encoder is always considered as a validator and thus doesn't need to be explicitly specified.

=end item1

=head2 hash-password($password)

This will hash a password with the encoder cipher, and return it (in crypt format). This will generally use a salt, and as such will return a different value each time even when called with the same password.

=head2 verify-password($password, $hash)

This will check a password satisfies a certain hash.

=head2 needs-rehash($hash)

This will check if a hash needs to be rehashed, either because it's in the wrong cipher or because the parameters are insufficient.

Calling this only ever makes sense after a password has been verified.

=head1 TIPS AND TRICKS

=head2 Custom configurations

While encoders generally allow for a default configuration, I would strongly encourage anyone to research what settings work for your application. It is generally a trade-off between usability/resources and security.

=head2 Unicode

C<Crypt::Passphrase> considers passwords to be text, and as such you should ensure any password input is decoded if it contains any non-ascii characters. C<Crypt::Passphrase> will take care of both normalizing and encoding such input.

=head2 DOS attacks

Hashing passwords is by its nature a heavy operations. It can be abused by malignant actors who want to try to DOS your application. It may be wise to do some form of DOS protection such as a proof-of-work schemei or a captcha.

=head2 Levels of security

In some situations, it may be appropriate to have different password settings for different users (e.g. set them more strict for administrators than for ordinary users).

=head1 SEE ALSO

=item L<Crypt::Passphrase::Argon2|Crypt::Passphrase::Argon2>

=item L<Crypt::Passphrase::Bcrypt|Crypt::Passphrase::Bcrypt>

=head1 AUTHOR

Leon Timmermans <fawaka@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2021 Leon Timmermans

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
