use Crypt::Passphrase::Encoder;

unit class Crypt::Passphrase::Argon2 does Crypt::Passphrase::Encoder;

use Crypt::SodiumPasswordHash;
use MIME::Base64;

method hash-password(Str $password) {
	return sodium-hash($password);
}

method needs-rehash(Str $hash) {
	return False;
}

method accepts-hash(Str $hash) {
	$hash eq 'argon2id';
}

method crypt-subtypes() {
	return 'argon2id';
}

method verify-password(Str $password, Str $hash) {
	return sodium-verify($hash, $password);
}

#ABSTRACT: An Argon2 encoder for Crypt::Passphrase

=begin pod

=method new(%args)

This creates a new Argon2 encoder, it currently takes no parameters yet.

=method hash-password($password)

This hashes the passwords with a random salt (and will thus return a different result each time).

=method needs-rehash($hash)

This returns true if the hash uses a different cipher.

=method crypt-types()

This class supports the following crypt types: C<argon2id>.

=method verify-password($password, $hash)

This will check if a password matches an argon2 hash.

=end pod
