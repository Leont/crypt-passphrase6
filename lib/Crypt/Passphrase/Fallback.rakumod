use Crypt::Passphrase::Validator;

unit class Crypt::Passphrase::Fallback does Crypt::Passphrase::Validator;

has &callback is required;
has &acceptor = anon sub accept-anything(Str $hash) { return True };

method accepts-hash(Str $hash) {
	return &.acceptor($hash);
}

method verify-password(Str $password, Str $hash) {
	return &.callback($password, $hash);
}

#ABSTRACT: a fallback validator for Crypt::Passphrase

=begin pod

=method new(%args)

This method takes two named arguments

=item * callback

The C<verify_password> method will call this with the password and the hash, and return its return value.

=item * acceptor

This callback will decide if this object will take a hash. By default it accepts anything.

=end pod
