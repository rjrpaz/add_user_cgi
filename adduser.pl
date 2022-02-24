#!/usr/bin/perl

use integer;

&parse_form_data (*FORM);
$name= $FORM{'name'};
$password= $FORM{'password'};
$password_conf= $FORM{'password_conf'};
$finger= $FORM{'finger'};
$username= $FORM{'username'};
$forward= $FORM{'forward'};
$shell= $FORM{'shell'};

$usuario_existe = "No";
$access_granted = "No";
@ip_address = ("1.2.3.4","127.0.0.1");
@salt_conjunto=("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9",".","/");

$remote_address = $ENV{'REMOTE_ADDR'};

foreach $ip_address (@ip_address) {
	if ($remote_address =~ /^$ip_address/) {
		$access_granted = "Yes";
	}
}

print "Content-type: text/html", "\n\n";
print "<HTML>", "\n";
print "<HEAD></HEAD>", "\n";
print "<BODY BACKGROUND=\"\" BGCOLOR=\"#ffffcc\">", "\n";

if ($access_granted eq "Yes"){

if (!$name){
	&return_error (500, "Error in form", "Please provide a valid real name for the user. ");
}

if (length($password) < 5){
	&return_error (500, "Error in form", "Password length should be at least 5 characters long. ");
}

if ($password ne $password_conf){
	&return_error (500, "Error in form", "Password and password confirmation are not equal. ");
}

if (!$username){
	&return_error (500, "Error in form", "Please provide a valid username. ");
}

open (PASSWD,'</etc/passwd');
while (<PASSWD>) {
	$usuario_existe="Yes" if /$username/;
}
close PASSWD;

if ($usuario_existe eq "Yes"){
	&return_error (500, "User exist", "Please, choose a different username. ");
}

$rand1 = int(rand 64) + 0;
$rand2 = int(rand 64) + 0;
$salt=$salt_conjunto[$rand1].$salt_conjunto[$rand2];

$cola_passwd = `/usr/bin/tail -n 1 /etc/passwd`;
($ultimo_uid) = ($cola_passwd =~ /\s*:x:([^:]*)/);

$fecha_seg = `/bin/date +%s`;
$date = $fecha_seg / 86400;

$p_crypt = crypt($password,$salt);

SWITCH: {
	$shell_final="sh", last SWITCH if ($shell eq "Bourne-Again Shell");
	$shell_final="tcsh", last SWITCH if ($shell eq "Extended C Shell");
	$shell_final="zsh", last SWITCH if ($shell eq "Z Shell");
	$shell_final="ash", last SWITCH if ($shell eq "A Shell");
}

$uid = $ultimo_uid + 1;
$add_passwd=$username.":x:".$uid.":100:".$name.",,,:/home/".$username.":/bin/".$shell_final."\n";
$add_shadow=$username.":".$p_crypt.":".$date.":0:99999:7:::\n";

open PASSWD, '>>/etc/passwd';
print PASSWD $add_passwd;
close PASSWD;

open SHADOW, '>>/etc/shadow';
print SHADOW $add_shadow;
close SHADOW;

print `mkdir /home/$username`;
print `chmod 711 /home/$username`;
print `cp /etc/skel/* /home/$username`;
print `chown -R $username:users /home/$username`;

open FINGER, ">/home/$username/.plan";
($finger_arreglado = $finger) =~ s/\r\n/\n/g;
print FINGER $finger_arreglado;
close FINGER;

if ($forward ne "") {
	open FORWARD, ">/home/$username/.forward";
	($forward_arreglado = $forward) =~ s/\r\n/\n/g;
	print FORWARD $forward_arreglado;
	close FORWARD;
}

print $salt,"<BR>";
print $add_passwd,"<BR>";
print $add_shadow,"<BR>";
# print $finger,"<BR>";

} else {
	print "Not allowed to access this server";
}

print "</BODY></HTML>", "\n";

exit (0);

sub parse_form_data
{
	local (*FORM_DATA) = @_;

	local ( $request_method, $query_string, @key_value_pairs, $key_value, $key,	$value);

	$request_method = $ENV{'REQUEST_METHOD'};

	if ($request_method eq "GET") {
		$query_string = $ENV{'QUERY_STRING'};
	} elsif ($request_method eq "POST") {
		read (STDIN, $query_string, $ENV{'CONTENT_LENGTH'});
	} else {
		&return_error (500, "Server error", "Method not supported.");
	}

	@key_value_pairs = split (/&/, $query_string);

	foreach $key_value (@key_value_pairs) {
		($key, $value) = split (/=/, $key_value);
		$value =~ tr/+/ /;
		$value =~ s/%([\dA-Fa-f][\dA-Fa-f])/pack ("C", hex ($1))/eg;

		if (defined($FORM_DATA{$key})) {
			$FORM_DATA{$key} = join ("\0", $FORM_DATA{$key}, $value);
		} else {
			$FORM_DATA{$key} = $value;
		}
	}
}

sub return_error
{
	local ($status, $keyword, $message) = @_;

	print "Content-type: text/html", "\n";
	print "Status: ", $status, " ", $keyword, "\n\n";

	print <<Error_End;

<TITLE>CGI - Unexpected error</TITLE>
<H1>$keyword</H1>
<H2>$message</H2><BR>
Please contact to <A HREF = mailto:root\@midomain.org>root\@midomain.org</A>to get more info.

Error_End

	exit(1);
}
