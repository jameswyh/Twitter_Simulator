# Twitter Simulator

## Problem definition
The goal of this is to implement a Twitter-like engine and (in part 2) pair up with Web Sockets to provide full functionality.<br/>
Specific things you have to do are: <br/>
### In part I, implement the following functionalities:<br/>
1. Registeraccountanddeleteaccount
2. Send tweet. Tweets can have hashtags (e.g. #COP5615isgreat) and mentions
(@bestuser). You can use predefines categories of messages for hashtags.
3. Subscribetouser'stweets.
4. Re-tweets (so that your subscribers get an interesting tweet you got by other
means).
5. Allow querying tweets subscribed to, tweets with specific hashtags, tweets in
which the user is mentioned (my mentions).
6. Iftheuserisconnected,delivertheabovetypesoftweetslive(withoutquerying).<br/>
Other considerations:<br/>
The client part (send/receive tweets) and the engine (distribute tweets) have to be in separate processes. Preferably, you use multiple independent client processes that simulate thousands of clients and a single-engine process.<br/>
1. Youneedtomeasurevariousaspectsofyoursimulatorandreportperformance.
2. Write test cases using the elixir’s built-in ExUnit test framework verifying the correctness for each task. Specifically, you need to write unit tests and functional tests (simple scenarios in which a tweet is sent, the user is mentioned or re-
tweets). Write 2-3 tests for each functionality.

### In part II:
1. Implement a simulation with at least 100 users.
2. Implement a web interface for the simulator you created project 4.1, using phoenix that allows access to the ongoing simulation using a web browser ( You might need to use the matching JavaScript library that allows Phoenix messages to be received in the browser). Create WebSockets using Phoenix channels. if you are creating a chart, you can use Charts.js

You need to show all the scenarios that you implemented in Part I.

## YouTube link for demo video:
https://youtu.be/7eR-p9tnmZs 

## Group members
Yihui Wang UFID# 8316-4355   
Wei Zhao UFID# 9144-4835

## Steps to run code
1. Open the Terminal and go to the directory of the project.
2. Type in the following command:
```
mix phx.server
```
If there are any prompt asking to install dependencies. please install them.
3. Open the web browser and visit [`localhost:4000`](http://localhost:4000)

## What function was implemented and how to run them
1. Register Account: To register user, input your username and password with space in between. Then click "Register Account" to register. For example, if the username is"111", password is "222", input: 
```
111 222
```
2. Delete Account: To delete account, simply input the current user's password and click "Delete Account"
3. Tweet: Type in the tweet you want to send and click "Tweet" button to send a new tweet. Tweets can have hashtags (e.g. COP5615isgreat) and mentions(@bestuser).
4. Retweet: Input the index number in the tweet list and click "Retweet" to retweet that tweet.
5. Subscribe: Input the username you want to follow and click "Subscribe".
6. Query Subscribed: Simply click this button to see the users you subcribed.
7. Query Hashtag: Input the name of hashtag topic (without the # symbol) and click Query Hashtag to see all related tweets for this topic.
8. Query Mention: Input the username (without the "@" symbol) and click "Query Mention"" to see all the tweets that mentioned that user.

## Implement a simulation with at least 100 users.
Please see attached "performance.pdf" for the simulation.
