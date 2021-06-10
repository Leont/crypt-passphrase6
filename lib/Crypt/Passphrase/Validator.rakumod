unit role Crypt::Passphrase::Validator;

method accepts-hash(Str $hash --> Bool) {
	...
}

method verify-password(Str $password, Str $hash --> Bool) {
	...
}

#ABSTRACT: Role for Crypt::Passphrase validators

=begin pod

=head1 DESCRIPTION

This is a role for validators. It requires any subclass to implement the following two methods:

=head2 accepts-hash($hash --> Bool)

This method returns true if this validator is able to process a hash. Typically this means that it's crypt identifier matches that of the validator.

=head2 verify-password($password, $hash --> Bool)

This checks if a C<$password> satisfies C<$hash>.

=end pod
