use Crypt::Passphrase::Validator;

unit role Crypt::Passphrase::Encoder does Crypt::Passphrase::Validator;

method needs-rehash(Str $hash --> Bool) {
	...;
}

method hash-password(Str $password --> Str) {
	...;
}

#ABSTRACT: Role for Crypt::Passphrase encoders

=begin pod

=head1 DESCRIPTION

This is a role for password encoders. It composes C<Crypt::Passphrase::Validator> and on top of the validator requirements it requires the following methods to be defined

=head2 hash_password($password --> Str)

This hashes a password. Note that this will return a new value each time since it uses a unique hash every time.

=head2  needs-rehash($hash --> Bool)

This method will return true if the password needs a rehash. This may either mean it's using a different hashing algoritm, or because it's using different parameters. This should be overloaded in your subclass.

=end pod
