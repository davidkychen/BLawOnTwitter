#!/usr/bin/perl

use LWP::Simple;
use Net::Twitter;


# Below information was removed due to pravicy issue
# $consumer_key = "need to add";
# $consumer_secret = "need to add";
# $token = "need to add";
# $token_secret = "need to add";

print "Enter UserID to begin: ";
$firstUserid = <>;
chomp $firstUserid;

#Connect to Twitter API. Need to add tokens and keys before connecting.
my $nt = Net::Twitter->new(
	traits => [qw/API::RESTv1_1/],
	consumer_key => $consumer_key,
	consumer_secret => $consumer_secret,
	access_token => $token,
	access_token_secret => $token_secret,
	);

#Twiter API has rate limit. The varaibles are set to count if certain limits are reached.
$requestCount = 0;
$checkCount = 0;
$user_count = 0;

#Function to get a user's friends ids and their friend numbers
sub getUserFriendlist{
 	my ($userid_check) = @_;
 	print "Capturing friend list of $userid_check........\n";
 	
 	#Check if request time reaches rate limit
 	checkRequestTimes();
 	$requestCount +=1;

 	#Request an account's friend list through Twitter API
 	my $friendList = $nt->friends({
 		user_id => $userid_check,
 		count => 200});

 	#Retrieve the needed information from the result
 	countFriend($userid_check, $friendList);

 	#Change the cursor to next one to keep retrieving information
 	$cursor = $friendList->{next_cursor};
	
 	print "Have sent $requestCount request(s)...\n";

 	#Iterate thorough the cursors and keep retrieving information until the account's friends infomation has been all retrieved
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
#Function to get only a user's friends ids 
sub friendListGetter{
	my($userid_check) = @_;
	$userid_global = $userid_check;
	print "Capturing friend list of $userid_check........\n";
	#checkRequestTimes2();
	if($requestCount2 < 15){
		$requestCount2 +=1;
		#Retrieve only an account's friend ids through Twitter API
		my $friendList = $nt->friends_ids({
			user_id => $userid_check,
			count => 5000});

		$cursor = $friendList->{next_cursor};

		#Retrieve the needed information(friend id) from the result
		countFriend2($userid_check, $friendList);
		print "Have sent $requestCount2 request(s)...\n";

		#Iterate through every cursor and retrieve information
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

#Function to count friends number
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
#Function to pass friend's ids to arrayFriendGetter
sub countFriend2{
	my($userid, $text) = @_;
	@toIterate = @{$text->{ids}};
	arrayFriendGetter(@toIterate);
}
#Function to get a bunch of ids' friend numbers
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
#Function to check if certain request has reached rate limit
sub checkRequestTimes{
	if($requestCount == 15){
		sleepFor15();
	}
}
#Function to check if certain request has reached rate limit
sub checkRequestTimes2{
	if($requestCount2 == 15){
		sleepFor15();
	}
}
#Function to check if certain request has reached rate limit
sub checkCheckTimes{
	if($checkCount == 180){
		sleepFor15();
	}
}
#Function to tell the app to sleep
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
#Function to check if an id exists
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
#Function to check if certain ids exist
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
#Function to check ratelimit
sub checkRateStatus{
	$checkRate = $nt->rate_limit_status;
	$lookupRate = $checkRate->{resources}->{statuses}->{"/statuses/lookup"}->{remaining};
	print "Look up rate: $lookupRate\n";
	print "\n";
}



$nowUserid = $firstUserid;

# Keep collecting account's friend number until reaching 50000 accounts
 while($user_count < 50000){
 	eval {
 		if($found != 1){
 			#Check if a user id exists or being protected
 			checkIfUserExist($nowUserid);
 		}
 		#getUserFriendlist($nowUserid);
 		#Retrieve a user id's friend information
		friendListGetter($nowUserid);
 		$user_count += 1;
 		print "Now has $user_count user data\n";

 		#Collect every 50000th user's friend information
 		$nowUserid += 50000;
 		$found = 0;
 	};
 	if($@){
 		warn "Error because: $@\n";
 		arrayCheck($nowUserid);
 		
 	}
 }

