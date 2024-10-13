use strict;
use warnings;

use CSS::Struct::Output::Indent;
use HTTP::Request;
use Plack::App::Message::Board::Message;
use Plack::Builder;
use Plack::Test;
use Tags::Output::Indent;
use Test::More 'tests' => 3;
use Test::NoWarnings;

# Test.
my $app = Plack::App::Message::Board::Message->new;
my $builder = Plack::Builder->new;
$builder->add_middleware('Session');
$builder->mount('/' => $app);
my $test = Plack::Test->create($builder->to_app);
my $res = $test->request(HTTP::Request->new(GET => '/'));
my $right_ret = <<"END";
<!DOCTYPE html>
<html lang="en"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" /><style type="text/css">
*{box-sizing:border-box;margin:0;padding:0;}.container{display:flex;align-items:flex-start;justify-content:center;height:1%;padding:0.5em;}.error{color:red;}.info{color:green;}.message-board{font-family:Arial, Helvetica, sans-serif;margin:1em;}.message-board .main-message{border:1px solid #ccc;padding:20px;border-radius:5px;background-color:#f9f9f9;max-width:600px;margin:auto;}.message-board .comments{max-width:600px;margin:auto;}.message-board .comment{border-left:2px solid #ccc;padding-left:10px;margin-top:20px;margin-left:10px;}.message-board .author{font-weight:bold;font-size:1.2em;}.message-board .comment .author{font-size:1em;}.message-board .date{color:#555;font-size:0.9em;margin-bottom:10px;}.message-board .comment .date{font-size:0.8em;}.message-board .text{margin-top:10px;white-space:pre-wrap;}textarea{width:100%;padding:12px 20px;margin:8px 0;display:inline-block;border:1px solid #ccc;border-radius:4px;box-sizing:border-box;}button{width:100%;background-color:#4CAF50;color:white;padding:14px 20px;margin:8px 0;border:none;border-radius:4px;cursor:pointer;}button:hover{background-color:#45a049;}.message-board .add-comment{max-width:600px;margin:auto;}.message-board .add-comment .title{margin-top:20px;font-weight:bold;font-size:1.2em;}button{margin:0;}textarea{width:100%;padding:12px 20px;margin:8px 0;display:inline-block;border:1px solid #ccc;border-radius:4px;box-sizing:border-box;}button{width:100%;background-color:#4CAF50;color:white;padding:14px 20px;margin:8px 0;border:none;border-radius:4px;cursor:pointer;}button:hover{background-color:#45a049;}.message-board-blank{margin:1em;}.message-board-blank .new-message-board{font-family:Arial, Helvetica, sans-serif;max-width:600px;margin:auto;}.message-board-blank .title{margin-top:20px;font-weight:bold;font-size:1.2em;}button{margin:0;}
</style></head><body><div class="container"><div class="inner" /></div><div id="main"><div class="message-board-blank"><div class="new-message-board"><div class="title">Add message board</div><form method="post"><textarea autofocus="autofocus" id="message_board_message" name="message_board_message" rows="6"></textarea><button type="submit" name="action" value="add_message_board">Save</button></form></div></div></div></body></html>
END
chomp $right_ret;
my $ret = $res->content;
is($ret, $right_ret, 'Get default main page in raw mode (blank message board).');

# Test.
$app = Plack::App::Message::Board::Message->new(
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
.message-board {
	font-family: Arial, Helvetica, sans-serif;
	margin: 1em;
}
.message-board .main-message {
	border: 1px solid #ccc;
	padding: 20px;
	border-radius: 5px;
	background-color: #f9f9f9;
	max-width: 600px;
	margin: auto;
}
.message-board .comments {
	max-width: 600px;
	margin: auto;
}
.message-board .comment {
	border-left: 2px solid #ccc;
	padding-left: 10px;
	margin-top: 20px;
	margin-left: 10px;
}
.message-board .author {
	font-weight: bold;
	font-size: 1.2em;
}
.message-board .comment .author {
	font-size: 1em;
}
.message-board .date {
	color: #555;
	font-size: 0.9em;
	margin-bottom: 10px;
}
.message-board .comment .date {
	font-size: 0.8em;
}
.message-board .text {
	margin-top: 10px;
	white-space: pre-wrap;
}
textarea {
	width: 100%;
	padding: 12px 20px;
	margin: 8px 0;
	display: inline-block;
	border: 1px solid #ccc;
	border-radius: 4px;
	box-sizing: border-box;
}
button {
	width: 100%;
	background-color: #4CAF50;
	color: white;
	padding: 14px 20px;
	margin: 8px 0;
	border: none;
	border-radius: 4px;
	cursor: pointer;
}
button:hover {
	background-color: #45a049;
}
.message-board .add-comment {
	max-width: 600px;
	margin: auto;
}
.message-board .add-comment .title {
	margin-top: 20px;
	font-weight: bold;
	font-size: 1.2em;
}
button {
	margin: 0;
}
textarea {
	width: 100%;
	padding: 12px 20px;
	margin: 8px 0;
	display: inline-block;
	border: 1px solid #ccc;
	border-radius: 4px;
	box-sizing: border-box;
}
button {
	width: 100%;
	background-color: #4CAF50;
	color: white;
	padding: 14px 20px;
	margin: 8px 0;
	border: none;
	border-radius: 4px;
	cursor: pointer;
}
button:hover {
	background-color: #45a049;
}
.message-board-blank {
	margin: 1em;
}
.message-board-blank .new-message-board {
	font-family: Arial, Helvetica, sans-serif;
	max-width: 600px;
	margin: auto;
}
.message-board-blank .title {
	margin-top: 20px;
	font-weight: bold;
	font-size: 1.2em;
}
button {
	margin: 0;
}
</style>
  </head>
  <body>
    <div class="container">
      <div class="inner" />
    </div>
    <div id="main">
      <div class="message-board-blank">
        <div class="new-message-board">
          <div class="title">
            Add message board
          </div>
          <form method="post">
            <textarea autofocus="autofocus" id="message_board_message" name=
              "message_board_message" rows="6" />
            <button type="submit" name="action" value="add_message_board">
              Save
            </button>
          </form>
        </div>
      </div>
    </div>
  </body>
</html>
END
chomp $right_ret;
$ret = $res->content;
is($ret, $right_ret, 'Get default main page in indent mode (blank message board).');
