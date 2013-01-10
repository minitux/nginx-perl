package minifycss;
use nginx;
use CSS::Minifier::XS;
use File::Basename;
use File::Path qw(make_path);

our $cache_dir= "";

sub handler {

  my $r = shift;
	my $filename = $r->filename;
	my $dir_uri=dirname($r->uri);

	$cache_dir2 = "$cache_dir$dir_uri";

	if (! -e $cache_dir2 ) {
		make_path("$cache_dir2");
	}

	my @splitted_uri = split ('\/', $r->uri);
	my $cache_file ="$cache_dir2/$splitted_uri[-1]";

	local $/=undef;

	return 404 unless -f $filename;

	open(INFILE, $filename) or die "Error reading file: $!";
	my $css = <INFILE>;
	close(INFILE);

	open(OUTFILE, '>' . $cache_file) or die "Error writing file: $!";
	print OUTFILE CSS::Minifier::XS::minify($css);
	close(OUTFILE);

	$r->send_http_header('text/css');

	$r->sendfile($cache_file);

	undef $r;
  undef $cache_dir2;
  undef $dir_uri;

	return OK;
}
1;
