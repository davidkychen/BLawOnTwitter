#!/usr/bin/perl

use LWP::Simple;
use Net::Twitter;

#combine from 373213004

$consumer_key = "8YFMkudnPUOwKVPAsxVuMJGZb";
$consumer_secret = "txo8GHZrOeazDXZSHlYmGTpD3FZj1EceZwLKwFRwQaxKopiF94";
$token = "1153513506-NOpzkdIuRws9s2rcYBqOCM9gfWUICTfUxSbT5Fi";
$token_secret = "9aYT9b9bEvDJ2kMrjwayfofhM9jYafhqVeSeJO2UVkc6x";
print "Enter UserID to begin: ";
$firstUserid = <>;
chomp $firstUserid;

my $nt = Net::Twitter->new(
	traits => [qw/API::RESTv1_1/],
	consumer_key => $consumer_key,
	consumer_secret => $consumer_secret,
	access_token => $token,
	access_token_secret => $token_secret,
	);

$requestCount = 0;
$checkCount = 0;
$user_count = 0;


sub getUserFriendlist{
 	my ($userid_check) = @_;
 	print "Capturing friend list of $userid_check........\n";
 	checkRequestTimes();
 	$requestCount +=1;
 	my $friendList = $nt->friends({
 		user_id => $userid_check,
 		count => 200});
 	countFriend($userid_check, $friendList);
 	$cursor = $friendList->{next_cursor};
	
 	print "Have sent $requestCount request(s)...\n";
 	while($cursor != 0){
 		checkRequestTimes();
 		$requestCount +=1;
 		my $friendList = $nt->friends({
 			user_id => $userid_check,
 			cursor => $cursor,
 			count => 200
 			});
 		print "Have sent $requestCount request(s)...\n";
 		countFriend($userid_check, $friendList);
 		$cursor = $friendList->{next_cursor};
 		print "Capturing $userid_check\'s Next cursor: $cursor\n";
 	}
 }
sub friendListGetter{
	my($userid_check) = @_;
	$userid_global = $userid_check;
	print "Capturing friend list of $userid_check........\n";
	#checkRequestTimes2();
	if($requestCount2 < 15){
		$requestCount2 +=1;
		my $friendList = $nt->friends_ids({
			user_id => $userid_check,
			count => 5000});
		$cursor = $friendList->{next_cursor};
		countFriend2($userid_check, $friendList);
		print "Have sent $requestCount2 request(s)...\n";
		while($cursor != 0){
			checkRequestTimes2();
			$requestCount2 +=1;
			my $friendList = $nt->friends_ids({
				user_id => $userid_check,
				cursor => $cursor,
				count => 5000
				});
			print "Have sent $requestCount2 request(s)...\n";
			countFriend2($userid_check, $friendList);
			$cursor = $friendList->{next_cursor};
			print "Capturing $userid_check\'s Next cursor: $cursor\n";
		}
	}else{
		getUserFriendlist($userid_check);
	}
}
sub countFriend{
 	my($userid, $text) = @_;
 	$toIterate = $text->{"users"};
 	open (OUTPUT, ">>chen_kuan_yu_final.csv");
 	foreach $index (keys $toIterate){
 		$friendid = $toIterate->[$index]->{"id"};
 		$count = $toIterate->[$index]->{"friends_count"};
 		#$friendCount{$userid}{$friendid} = $count;
 		print OUTPUT "$userid,$friendid,$count\n";
 	}
 	close (OUTPUT);
 }
sub countFriend2{
	my($userid, $text) = @_;
	@toIterate = @{$text->{ids}};
	arrayFriendGetter(@toIterate);
}
sub arrayFriendGetter{
	my(@userids) = @_;
	$key = 0;
	$i = 0;
	$max = 99;
	$x = 99;
	$l = scalar @userids;
	while($i < scalar @userids){
		@searchArr =();
		for($i;$i<$max;$i++){
			push(@searchArr, $userids[$i]);
		}
		$i = $i+ 1;
		$max = $max + $x;
		if($max > $l){
			$max = $l;
		}
		checkCheckTimes();
		$checkCount += 1;
		
		print "Capturing ids: " . join(",",@searchArr) . "\n";
		$check = $nt->lookup_users({
			user_id => join(",",@searchArr)
			});
		open (OUTPUT, ">>chen_kuan_yu_final.csv");
		foreach $index (keys $check){
			$tempId = $check->[$index]->{id};
			$tempCount = $check->[$index]->{friends_count};
			print OUTPUT "$userid_global,$tempId,$tempCount\n";
		}
		close (OUTPUT);
	}	
}

sub checkRequestTimes{
	if($requestCount == 15){
		sleepFor15();
	}
}
sub checkRequestTimes2{
	if($requestCount2 == 15){
		sleepFor15();
	}
}
sub checkCheckTimes{
	if($checkCount == 180){
		sleepFor15();
	}
}

sub sleepFor15{
	print "Have already reached rate limit.\n";
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
		printf("Time Format - HH:MM:SS\n");
		printf("%02d:%02d:%02d", $hour, $min, $sec);
		print "\n";
		print "The program will stopped for 15 minutes and then continue again\n";
		sleep 180;
		print "12 minutes to resume capturing......\n";
		sleep 180;
		print "9 minutes to resume capturing......\n";
		sleep 180;
		print "6 minutes to resume capturing......\n";
		sleep 180;
		print "3 minutes to resume capturing......\n";
		sleep 240;
		$checkCount = 0;
		$requestCount = 0;
		$checkCount2 = 0;
		$requestCount2 = 0;
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
		printf("Time Format - HH:MM:SS\n");
		printf("%02d:%02d:%02d", $hour, $min, $sec);
		print "\n";
}
sub checkIfUserExist{
	my($userid) = @_;
	checkCheckTimes();
	$checkCount +=1;
	print "Checking if User ID: $userid exists...\n";
	$check = $nt->lookup_users({
	user_id => $userid
	});
	$friend_number = $check->[0]->{friends_count};
	if($friend_number > 2000 || $friend_number < 100){
		die "Friend number not in the target range";
	}
}

sub arrayCheck{
	my($userid) = @_;
	@searchArr =();
	$found = 0;
	while($found != 1){
		@searchArr =();
		$key = 0;
		checkCheckTimes();
		$checkCount += 1;
		print "Performing checking 100 IDs....\n";
		for(1..99){
			push(@searchArr, $userid+$_);
		}
		$userid = $searchArr[98];
		$nowUserid = $userid;

		eval{$check = $nt->lookup_users({
				user_id => join(",",@searchArr)
			});
			print "Ckecking if IDs: " . join(",",@searchArr) . " exist\n";
			while($found == 0 && $key < 99){
				if($check->[$key]->{friends_count} <= 2000 && $check->[$key]->{friends_count} >= 100){
					$nowUserid = $check->[$key]->{id};
					print "Found $nowUserid exists!!!\n";
					$found = 1;
				}
				$key += 1;
			}
		};
		if($@){
 			warn "Error because: $@\n";
 		}
	}
}

sub checkRateStatus{
	$checkRate = $nt->rate_limit_status;
	$lookupRate = $checkRate->{resources}->{statuses}->{"/statuses/lookup"}->{remaining};
	print "Look up rate: $lookupRate\n";
	print "\n";
}



$nowUserid = $firstUserid;


 while($user_count < 50000){
 	eval {
 		if($found != 1){
 			checkIfUserExist($nowUserid);
 		}
 		#getUserFriendlist($nowUserid);
		friendListGetter($nowUserid);
 		$user_count += 1;
 		print "Now has $user_count user data\n";
 		$nowUserid += 50000;
 		$found = 0;
 	};
 	if($@){
 		warn "Error because: $@\n";
 		arrayCheck($nowUserid);
 		
 	}
 }

