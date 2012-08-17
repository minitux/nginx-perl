package resizer;
use strict;
use warnings;
use nginx;
use Image::Magick;

# add your correct path 

our $base_dir = "";
our $dest_dir = "";
our $max_size = 3000;


sub handler {

	my $r = shift;
	my $uri=$r->uri;

	# my images uri is like /images/widhth/height/name.extension 

	my @splitted_uri = split ('\/', $uri);
	my @splitted_filename = split ('\.', $splitted_uri[4]);

	my $width = $splitted_uri[2]; 
	my $height = $splitted_uri[3];
	my $name = $splitted_filename[0];
	my $ext = $splitted_filename[1];
	my $file_path = "$base_dir$name.$ext";

	my $dest_file = "$dest_dir${width}.${height}.$name.$ext";

	my @allowed_size = (
			'35x35', '45x45', '55x55','70x35', '80x80', '90x45',
			'110x55', '130x65', '138x69', '155x78', '160x80',
			'170x0', '170x170', '180x90', '190x95', '190x220',
			'200x100', '230x115', '270x100', '277x205', '280x40',
			'280x140', '288x144', '290x145', '298x149',
			'480x145','300x60', '300x250', '316x158', '370x0', '380x130',
			'580x290', '570x290', '580x130','1024x476', '0x0'
	);
	
	my $size = $width."x".$height;

	return 404 unless $size ~~ @allowed_size;
	return 404 unless $ext =~ /jpe?g|png|gif|JPE?G|PNG|GIF/;
	return 404 if !-e $file_path;

	$r->send_http_header;
	my $image = new Image::Magick;
	$image->Read($file_path);
	$height = $width*$image->Get('height')/$image->Get('width');

	$image->Set(Gravity => 'Center');
	$image->Set(background => '#fff');


	if($width != 0){
		$image->Scale(width=>$width, height=>$height);
	}
	$image->Crop(geometry => $size);
	$image->Write($dest_file);
	$r->sendfile($dest_file);
	return OK;
}
1;
__END__
