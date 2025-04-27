use strict;
use warnings;

use CSS::Struct::Output::Indent;
use HTTP::Request;
use Plack::App::Message::Board::List;
use Plack::Builder;
use Plack::Test;
use Tags::Output::Indent;
use Test::More 'tests' => 3;
use Test::NoWarnings;

# Test.
my $app = Plack::App::Message::Board::List->new;
my $builder = Plack::Builder->new;
$builder->add_middleware('Session');
$builder->mount('/' => $app);
my $test = Plack::Test->create($builder->to_app);
my $res = $test->request(HTTP::Request->new(GET => '/'));
my $right_ret = <<"END";
<!DOCTYPE html>
<html lang="en"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" /><style type="text/css">
*{box-sizing:border-box;margin:0;padding:0;}.container{display:flex;align-items:flex-start;justify-content:center;height:1%;padding:0.5em;}.error{color:red;}.info{color:green;}.table,.table td,.table th{border:1px solid #ddd;text-align:left;}.table{border-collapse:collapse;width:100%;}.table th,.table td{padding:15px;}#main{margin:1em;font-family:Arial, Helvetica, sans-serif;}.links{margin-bottom:1em;}
</style></head><body><div class="container"><div class="inner"><div class="messages"><span class="error">No callback for message board list.</span></div></div></div><div id="main"><div class="links"><a href="/message">Add new message</a></div><table class="table"><tr><th>Id</th><th>Author</th><th>Date</th><th>Message</th><th>Number of comments</th></tr><tr><td colspan="5">No message boards.</td></tr></table></div></body></html>
END
chomp $right_ret;
my $ret = $res->content;
is($ret, $right_ret, 'Get default main page in raw mode (no message board list callback).');

# Test.
$app = Plack::App::Message::Board::List->new(
	'css' => CSS::Struct::Output::Indent->new,
	'tags' => Tags::Output::Indent->new(
		'preserved' => ['style'],
		'xml' => 1,
	),
);
$builder = Plack::Builder->new;
$builder->add_middleware('Session');
$builder->mount('/' => $app);
$test = Plack::Test->create($builder->to_app);
$res = $test->request(HTTP::Request->new(GET => '/'));
$right_ret = <<"END";
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <style type="text/css">
* {
	box-sizing: border-box;
	margin: 0;
	padding: 0;
}
.container {
	display: flex;
	align-items: flex-start;
	justify-content: center;
	height: 1%;
	padding: 0.5em;
}
.error {
	color: red;
}
.info {
	color: green;
}
.table, .table td, .table th {
	border: 1px solid #ddd;
	text-align: left;
}
.table {
	border-collapse: collapse;
	width: 100%;
}
.table th, .table td {
	padding: 15px;
}
#main {
	margin: 1em;
	font-family: Arial, Helvetica, sans-serif;
}
.links {
	margin-bottom: 1em;
}
</style>
  </head>
  <body>
    <div class="container">
      <div class="inner">
        <div class="messages">
          <span class="error">
            No callback for message board list.
          </span>
        </div>
      </div>
    </div>
    <div id="main">
      <div class="links">
        <a href="/message">
          Add new message
        </a>
      </div>
      <table class="table">
        <tr>
          <th>
            Id
          </th>
          <th>
            Author
          </th>
          <th>
            Date
          </th>
          <th>
            Message
          </th>
          <th>
            Number of comments
          </th>
        </tr>
        <tr>
          <td colspan="5">
            No message boards.
          </td>
        </tr>
      </table>
    </div>
  </body>
</html>
END
chomp $right_ret;
$ret = $res->content;
is($ret, $right_ret, 'Get default main page in indent mode (no message board list callback).');
